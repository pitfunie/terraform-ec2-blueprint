# Save as setup-ec2-ssm.sh, make executable with chmod +x setup-ec2-ssm.sh, then run

Bash

./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f

# GitHub Setup Instructions

# Method 1: Download and Execute (Recommended)

## In CloudShell, download the script

curl -O <https://raw.githubusercontent.com/pitfunie/layer3-soc-platform/main/scripts/setup-ec2-ssm.sh>

## Make it executable

chmod +x setup-ec2-ssm.sh

## Run it with your instance ID

./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f

# Method 2: Direct Execution (One-liner)

Runs directly without saving to disk

curl -s <https://raw.githubusercontent.com/pitfunie/layer3-soc-platform/main/scripts/setup-ec2-ssm.sh> | bash -s -- i-00b4cbe3cd458dc3f

# Setting Up Your GitHub Repository

1. Create the script path in your repo:

## In your local repo

mkdir -p scripts
cp setup-ec2-ssm.sh scripts/
git add scripts/setup-ec2-ssm.sh
git commit -m "Add EC2 SSM setup automation"
git push origin main

1. Verify it's accessible:

## Test the raw URL works

curl -I <https://raw.githubusercontent.com/pitfunie/layer3-soc-platform/main/scripts/setup-ec2-ssm.sh>

1. Quick CloudShell alias for your team:

## Add to CloudShell

alias setup-ssm='curl -s <https://raw.githubusercontent.com/pitfunie/layer3-soc-platform/main/scripts/setup-ec2-ssm.sh> | bash -s --'

## Then just run

setup-ssm i-00b4cbe3cd458dc3f

## Default usage

./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f

## Custom role/profile names

SSM_ROLE_NAME="MyCustomRole" SSM_PROFILE_NAME="MyCustomProfile" ./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f

## Or export for multiple runs

export SSM_ROLE_NAME="ProdSSMRole"
export SSM_PROFILE_NAME="ProdSSMProfile"
./setup-ec2-ssm.sh i-instance1
./setup-ec2-ssm.sh i-instance2

## Configuration Variables

    SSM_ROLE_NAME: IAM role name (default: EC2-SSM-Role)

    SSM_PROFILE_NAME: Instance profile name (default: EC2-SSM-Role)

The inline policy name is fixed as "SSMCoreInline" but you can modify the script if needed.

Add this to the script's configuration section:

# Configuration

POLICY_NAME="${SSM_POLICY_NAME:-SSMCoreInline}"

Then update the README:

## Configuration Variables

- `SSM_ROLE_NAME`: IAM role name (default: EC2-SSM-Role)
- `SSM_PROFILE_NAME`: Instance profile name (default: EC2-SSM-Role)
- `SSM_POLICY_NAME`: Inline policy name (default: SSMCoreInline)

## Example: Custom everything

SSM_ROLE_NAME="ProdRole" SSM_PROFILE_NAME="ProdProfile" SSM_POLICY_NAME="ProdPolicy" ./setup-ec2-ssm.sh i-instance1
