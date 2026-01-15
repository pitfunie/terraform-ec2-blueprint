#!/bin/bash
# setup-ec2-ssm.sh - Automated EC2 Session Manager Setup for CloudShell
# Author: Mike Williams | Milieucloud LLC
# Description: Production-ready script with full validation and error recovery

set -euo pipefail
# This makes the script stop if something goes wrong,
# so we don’t keep running broken commands.

# -------------------------
# Configuration
# -------------------------
# These are the names we use for AWS things.
# If the user didn’t give us names, we use the default ones.
ROLE_NAME="${SSM_ROLE_NAME:-EC2-SSM-Role}"
PROFILE_NAME="${SSM_PROFILE_NAME:-EC2-SSM-Role}"
POLICY_NAME="SSMCoreInline"

MAX_WAIT=60  # How long we wait (in seconds) before giving up.

# -------------------------
# Colors for output
# -------------------------
# These make the script print messages in color,
# so it's easier to see what's good, bad, or a warning.
RED='\033[0;31m'     # Red = something went wrong
GREEN='\033[0;32m'   # Green = everything is good
YELLOW='\033[1;33m'  # Yellow = be careful
NC='\033[0m'         # No Color = back to normal text

# -------------------------
# Logging functions
# -------------------------
# These are shortcuts to print messages with colors.
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }   # Good news
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }  # Warning
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }    # Bad news

# -------------------------
# Validation functions
# -------------------------
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # This checks if AWS knows who you are.
    # If it doesn’t, that means your login is missing or expired.
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or expired."
        exit 1
    fi

    # Get the AWS account number we’re working in.
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    log_info "Working in account: $ACCOUNT_ID"
}

# -------------------------
# IAM Setup Functions
# -------------------------
setup_iam_role() {
    log_info "Setting up IAM role..."
    
    # Check if the role already exists.
    # A "role" is like a special costume EC2 machines wear
    # so AWS knows what they’re allowed to do.
    if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
        log_warn "Role $ROLE_NAME already exists, skipping creation"
    else
        # Make a trust policy.
        # This is basically a note saying:
        # “Hey AWS, EC2 machines are allowed to use this role.”
        cat > /tmp/ec2-trust.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF
        
        # Create the role using the trust policy.
        aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document file:///tmp/ec2-trust.json \
            --description "Role for EC2 SSM access" > /dev/null
        
        log_info "Created role: $ROLE_NAME"
        rm -f /tmp/ec2-trust.json
    fi
    
    # Attach the AWS-managed SSM policy.
    # This gives the EC2 machine the powers it needs to talk to SSM.
    if aws iam list-attached-role-policies --role-name "$ROLE_NAME" \
        | grep -q "AmazonSSMManagedInstanceCore"; then
        log_info "Managed policy already attached"
    else
        aws iam attach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
        log_info "Attached AWS managed policy"
    fi
}

setup_instance_profile() {
    log_info "Setting up instance profile..."
    
    # Check if the instance profile already exists.
    # An instance profile is like a backpack that holds the role
    # so the EC2 machine can actually use it.
    if aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" &> /dev/null; then
        log_warn "Instance profile $PROFILE_NAME exists"
        
        # Make sure the profile actually has a role inside the backpack.
        ROLES=$(aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" \
            --query 'InstanceProfile.Roles[*].RoleName' --output text)
        
        if [[ -z "$ROLES" ]]; then
            # If the backpack is empty, put the role inside it.
            log_warn "Instance profile exists but has NO ROLE - fixing..."
            aws iam add-role-to-instance-profile \
                --instance-profile-name "$PROFILE_NAME" \
                --role-name "$ROLE_NAME"
            log_info "Added role to existing profile"
        else
            log_info "Profile has role: $ROLES"
        fi
    else
        # If the profile doesn’t exist, create a new backpack
        # and put the role inside it.
        aws iam create-instance-profile --instance-profile-name "$PROFILE_NAME"
        aws iam add-role-to-instance-profile \
            --instance-profile-name "$PROFILE_NAME" \
            --role-name "$ROLE_NAME"
        log_info "Created instance profile with role"
    fi
}

# -------------------------
# Wait for AWS state changes
# -------------------------
wait_for_state() {
    local instance_id=$1
    local target_state=$2
    local elapsed=0
    
    # This loop keeps checking the instance until it reaches the state we want.
    # Think of it like asking every few seconds: “Are we there yet?”
    while [[ $elapsed -lt $MAX_WAIT ]]; do
        STATE=$(aws ec2 describe-iam-instance-profile-associations \
            --filters "Name=instance-id,Values=$instance_id" \
            --query 'IamInstanceProfileAssociations[0].State' --output text 2>/dev/null || echo "none")
        
        # If the instance is in the state we want, we’re done.
        if [[ "$STATE" == "$target_state" ]]; then
            return 0
        fi
        
        # If not, wait a little and try again.
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
    done
    
    echo
    # If we waited too long, give up.
    return 1
}

# -------------------------
# Attach profile to instance
# -------------------------
attach_to_instance() {
    local instance_id=$1
    
    log_info "Processing instance: $instance_id"
    
    # First, make sure the instance actually exists.
    if ! aws ec2 describe-instances --instance-ids "$instance_id" &> /dev/null; then
        log_error "Instance $instance_id not found"
        return 1
    fi
    
    # Check if the instance already has a profile attached.
    CURRENT_ASSOC=$(aws ec2 describe-iam-instance-profile-associations \
        --filters "Name=instance-id,Values=$instance_id" \
        --query 'IamInstanceProfileAssociations[0]' --output json)
    
    if [[ "$CURRENT_ASSOC" != "null" ]]; then
        STATE=$(echo "$CURRENT_ASSOC" | jq -r '.State')
        ASSOC_ID=$(echo "$CURRENT_ASSOC" | jq -r '.AssociationId')
        CURRENT_PROFILE=$(echo "$CURRENT_ASSOC" | jq -r '.IamInstanceProfile.Arn' | awk -F'/' '{print $NF}')
        
        # If the instance already has the right profile and it’s active, we’re good.
        if [[ "$CURRENT_PROFILE" == "$PROFILE_NAME" && "$STATE" == "associated" ]]; then
            log_info "Instance already has correct profile attached"
            return 0
        else
            # Otherwise, remove the old profile.
            log_warn "Removing existing association (Profile: $CURRENT_PROFILE, State: $STATE)"
            aws ec2 disassociate-iam-instance-profile --association-id "$ASSOC_ID"
            
            # Wait until AWS confirms the profile is removed.
            echo -n "Waiting for disassociation"
            if ! wait_for_state "$instance_id" "none"; then
                log_error "Timeout waiting for disassociation"
                return 1
            fi
            echo " done"
        fi
    fi
    
    # Attach the correct instance profile.
    log_info "Attaching instance profile..."
    ASSOC_OUTPUT=$(aws ec2 associate-iam-instance-profile \
        --instance-id "$instance_id" \
        --iam-instance-profile Name="$PROFILE_NAME" \
        --output json)
    
    NEW_ASSOC_ID=$(echo "$ASSOC_OUTPUT" | jq -r '.IamInstanceProfileAssociation.AssociationId')
    
    # Wait until AWS says the new profile is attached.
    echo -n "Waiting for association"
    if ! wait_for_state "$instance_id" "associated"; then
        log_error "Timeout waiting for association. Check AWS console."
        return 1
    fi
    echo " done"
    
    log_info "Association complete: $NEW_ASSOC_ID"
}

# -------------------------
# Verify SSM registration
# -------------------------
verify_ssm_registration() {
    local instance_id=$1
    local attempts=0
    local max_attempts=12  # We try for about 1 minute total.
    
    log_info "Waiting for SSM agent registration..."
    
    # This loop checks if the SSM agent has checked in with AWS yet.
    # It’s like waiting for someone to say “I’m online!”
    while [[ $attempts -lt $max_attempts ]]; do
        if aws ssm describe-instance-information \
            --filters "Key=InstanceIds,Values=$instance_id" \
            --query 'InstanceInformationList[0].PingStatus' \
            --output text 2>/dev/null | grep -q "Online"; then
            
            log_info "✓ Instance registered with SSM successfully!"
            return 0
        fi
        
        sleep 5
        attempts=$((attempts + 1))
        echo -n "."
    done
    
    echo
    log_warn "Instance not showing in SSM yet. Agent may need restart on instance."
    log_warn "To check: aws ssm describe-instance-information"
    return 1
}

# -------------------------
# Main execution
# -------------------------
main() {
    local instance_id="$1"
    
    # Make sure the user gave us an instance ID.
    if [[ -z "$instance_id" ]]; then
        echo "Usage: $0 <instance-id>"
        echo "Example: $0 i-0123456789abcdef"
        exit 1
    fi
    
    log_info "Starting EC2 SSM setup for instance: $instance_id"
    
    # Run all the setup steps in order.
    check_prerequisites
    setup_iam_role
    setup_instance_profile
    
    # Try attaching the profile and then check SSM registration.
    if attach_to_instance "$instance_id"; then
        verify_ssm_registration "$instance_id"
        
        log_info "Setup complete! Test with:"
        echo "aws ssm start-session --target $instance_id"
    else
        log_error "Setup failed. Check CloudTrail for details."
        exit 1
    fi
}

# Start the script with whatever arguments the user gave.
main "$@"
