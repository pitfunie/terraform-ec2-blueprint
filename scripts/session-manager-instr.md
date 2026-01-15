```

# This file is part of the terraform-ec2-blueprint project
# Copyright (C) 2026  Michael WyCliff Williams

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version

# This program is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>
```

# 🚀 How to Run This Script (Local, GitHub, CloudShell)

## Below is a polished, crystal‑clear execution guide that matches your workflow and your team‑enablement style

# ✅ 1. Run the script locally

```
setup-ec2-ssm.sh
```

## Make it executable

```
chmod +x setup-ec2-ssm.sh
```

## Run it

```
./setup-ec2-ssm.sh i-INSTANCE-ID

./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f
```

# AWS EC2 Session Manager Setup Guide

## Overview

```
This guide provides a complete setup process for enabling AWS Systems Manager Session Manager access to EC2 instances using AWS CloudShell. Session Manager provides secure, auditable instance access without SSH keys or bastion hosts.
```

## Prerequisites

```
    AWS CloudShell access with appropriate IAM permissions

    EC2 instance running Amazon Linux 2023 (or other OS with SSM Agent installed)

    Security Group with outbound HTTPS (port 443) allowed for AWS endpoints

    Instance ID ready for configuration
```

## Architecture Components

```
    IAM Role: Contains permissions for SSM operations

    Instance Profile: Wrapper that allows EC2 to assume the IAM role

    SSM Agent: Pre-installed service on AL2023 that communicates with AWS Systems Manager

    VPC Endpoints (optional): For private instances without internet access
```

## Setup Process

## Phase 1: IAM Configuration (Execute ALL in CloudShell)

## 1.1 Create Policy Documents

## Create inline policy for core SSM permissions

```
cat << 'EOF' > ssm-core-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```

## Create EC2 trust policy

```
cat << 'EOF' > ec2-trust.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

## Verify files created

```
ls -la *.json
```

## 1.2 Create IAM Role with Policies

## Create the IAM role

```
aws iam create-role \
  --role-name EC2-SSM-Role \
  --assume-role-policy-document file://ec2-trust.json
```

## Attach inline policy for granular control

```
aws iam put-role-policy \
  --role-name EC2-SSM-Role \
  --policy-name SSMCoreInline \
  --policy-document file://ssm-core-policy.json
```

## Attach AWS-managed policy for comprehensive SSM access

```
aws iam attach-role-policy \
  --role-name EC2-SSM-Role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

## Verify both policies are attached

```
echo "Inline policies:"
aws iam list-role-policies --role-name EC2-SSM-Role

echo "Managed policies:"
aws iam list-attached-role-policies --role-name EC2-SSM-Role
```

# 1.3 Create and Configure Instance Profile

## Create instance profile

```
aws iam create-instance-profile \
  --instance-profile-name EC2-SSM-Role
```

# CRITICAL STEP: Add role to instance profile

## This step is often missed but is essential

```
aws iam add-role-to-instance-profile \
  --instance-profile-name EC2-SSM-Role \
  --role-name EC2-SSM-Role
```

## Verify role is in profile (MUST show ["EC2-SSM-Role"], not empty [])

```
aws iam get-instance-profile \
  --instance-profile-name EC2-SSM-Role \
  --query 'InstanceProfile.Roles[*].RoleName'
```

# Phase 2: Attach to EC2 Instance (Execute in CloudShell)

## 2.1 Associate Instance Profile

## Set your instance ID

```
INSTANCE_ID="i-XXXXXXXXXXXXX"  # Replace with your instance ID
```

## Check if instance already has a profile attached

```
aws ec2 describe-iam-instance-profile-associations \
  --filters Name=instance-id,Values=$INSTANCE_ID
```

## If output shows existing association, note the AssociationId and disassociate first

## aws ec2 disassociate-iam-instance-profile --association-id iip-assoc-XXXXX

## Associate the new instance profile

```
aws ec2 associate-iam-instance-profile \
  --instance-id $INSTANCE_ID \
  --iam-instance-profile Name=EC2-SSM-Role
```

## Monitor association status (wait for "associated" not "associating")

```
watch -n 5 'aws ec2 describe-iam-instance-profile-associations \
  --filters Name=instance-id,Values='$INSTANCE_ID' \
  --query "IamInstanceProfileAssociations[0].[State,AssociationId]"'
```

# 2.2 Verify Instance Profile Attachment

## Check that state is "associated" (not "associating")

```
aws ec2 describe-iam-instance-profile-associations \
  --filters Name=instance-id,Values=$INSTANCE_ID \
  --query 'IamInstanceProfileAssociations[0].State'
```

# Phase 3: Configure SSM Agent (Execute ON the EC2 Instance)

## Important: These commands must run ON the EC2 instance, not in CloudShell

## Connect via SSH or EC2 Instance Connect

## 3.1 Verify Credentials Access

# Check if instance can access its role (using IMDSv2)

```
TOKEN=$(curl -s -X PUT "<http://169.254.169.254/latest/api/token>" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  <http://169.254.169.254/latest/meta-data/iam/security->
```
