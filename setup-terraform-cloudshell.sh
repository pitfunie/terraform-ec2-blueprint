#!/bin/bash
# setup-terraform-cloudshell.sh
# Install terraform in AWS CloudShell

set -euo pipefail

TERRAFORM_VERSION="1.6.6"
echo "Installing Terraform ${TERRAFORM_VERSION}..."

curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
unzip -q terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
rm terraform.zip

terraform version
echo "✓ Terraform installed successfully"
