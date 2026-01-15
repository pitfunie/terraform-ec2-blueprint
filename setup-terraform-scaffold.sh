#!/bin/bash
set -euo pipefail
# This makes the script stop if something goes wrong.

# -------------------------
# Logging helpers
# -------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -------------------------
# Create Terraform scaffold
# -------------------------
log_info "Creating Terraform project scaffold..."

mkdir -p terraform-demo/modules/ec2-linux-demo
mkdir -p terraform-demo/scripts

cd terraform-demo

# -------------------------
# Top-level Terraform files
# -------------------------
# These files are like the brain of your Terraform setup.
# They tell AWS what to do, and how to do it.

touch provider.tf       # Sets up AWS region and provider
touch main.tf           # Main logic for calling modules
touch variables.tf      # Input variables for reuse
touch outputs.tf        # Outputs like instance ID or IP
touch terraform.tfvars  # Actual values for variables

log_info "Created top-level Terraform files."

# -------------------------
# Module: ec2-linux-demo
# -------------------------
cd modules/ec2-linux-demo

# This folder holds the EC2 logic.
# It’s like a reusable LEGO block for launching EC2.

touch main.tf           # EC2 logic goes here
touch variables.tf      # EC2 module inputs
touch outputs.tf        # EC2 module outputs

log_info "Created EC2 module files."

# -------------------------
# Script directory
# -------------------------
cd ../../scripts

# These are your provisioning scripts.
# They run after Terraform finishes to set up SSM and IAM.

touch setup-ec2-ssm.sh  # Your SSM provisioning script
touch setup-ec2-enh.sh  # Your IAM inline policy enhancer

log_info "Created script placeholders."

# -------------------------
# Done
# -------------------------
cd ..
log_info "✅ Terraform scaffold is ready!"
log_info "You can now start filling in each file with real logic."
