#!/bin/bash
set -euo pipefail
# This makes the script stop if something goes wrong,
# so we don’t keep running broken commands.

# -------------------------
# Configuration
# -------------------------
# This is the IAM role we are adding extra powers to.
# If the user didn’t give us a name, we use the default one.
ROLE_NAME="${SSM_ROLE_NAME:-EC2-SSM-Role}"

# -------------------------
# Colors for output
# -------------------------
GREEN='\033[0;32m'   # Green = everything is good
YELLOW='\033[1;33m'  # Yellow = warning
RED='\033[0;31m'     # Red = something went wrong
NC='\033[0m'         # No Color = normal text

# -------------------------
# Logging helpers
# -------------------------
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -------------------------
# Check AWS login
# -------------------------
check_prerequisites() {
    log_info "Checking AWS login..."

    # This checks if AWS knows who you are.
    # If it doesn’t, your login is missing or expired.
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or expired."
        exit 1
    fi

    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    log_info "Working in AWS account: $ACCOUNT_ID"
}

# -------------------------
# Apply EC2 lifecycle policy
# -------------------------
apply_ec2_lifecycle_policy() {
    log_info "Creating EC2 lifecycle policy..."

    # This file tells AWS what EC2 actions the role is allowed to do.
    # Think of it like giving the role a permission slip.
    cat > /tmp/ec2-lifecycle.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF

    log_info "Applying EC2Lifecycle inline policy..."
    aws iam put-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "EC2Lifecycle" \
        --policy-document file:///tmp/ec2-lifecycle.json

    log_info "Verifying EC2Lifecycle policy..."
    aws iam get-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "EC2Lifecycle" > /dev/null

    log_info "EC2 lifecycle policy applied successfully!"
}

# -------------------------
# Apply CloudWatch read policy
# -------------------------
apply_cloudwatch_policy() {
    log_info "Creating CloudWatch read policy..."

    # This file gives the role permission to read CloudWatch metrics.
    # It's like giving the role a pair of binoculars to look at EC2 stats.
    cat > /tmp/cloudwatch-read.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData"
      ],
      "Resource": "*"
    }
  ]
}
EOF

    log_info "Applying CloudWatchRead inline policy..."
    aws iam put-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "CloudWatchRead" \
        --policy-document file:///tmp/cloudwatch-read.json

    log_info "Verifying CloudWatchRead policy..."
    aws iam get-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "CloudWatchRead" > /dev/null

    log_info "CloudWatch read policy applied successfully!"
}

# -------------------------
# Main function
# -------------------------
main() {
    log_info "Starting enhanced IAM policy setup for role: $ROLE_NAME"

    check_prerequisites
    apply_ec2_lifecycle_policy
    apply_cloudwatch_policy

    log_info "All inline policies applied successfully!"
    log_info "This enhances your EC2 SSM setup with extra powers."
}

main "$@"
