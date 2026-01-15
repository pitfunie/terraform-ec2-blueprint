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

setup-ec2-ssm.sh

## Make it executable

```
chmod +x setup-ec2-ssm.sh
```

## Run it

```
./setup-ec2-ssm.sh i-INSTANCE-ID

./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f
```

# ✅ 2. Push the script to your GitHub repo

## From your local machine

```
git add setup-ec2-ssm.sh
git commit -m "Add EC2 SSM setup script"
git push origin main
```

## If your repo structure uses a scripts/ folder (recommended)

```
mkdir -p scripts
mv setup-ec2-ssm.sh scripts/
git add scripts/setup-ec2-ssm.sh
git commit -m "Organize script under scripts/"
git push origin main
```

## Verify the raw URL works

```
curl -I <https://raw.githubusercontent.com/YOUR-USER/YOUR-REPO/main/scripts/setup-ec2-ssm.sh>
```

# ✅ 3. Run the script from CloudShell (download + execute)

## This is the “team‑friendly” method where CloudShell pulls the script from GitHub

```
curl -O <https://raw.githubusercontent.com/YOUR-USER/YOUR-REPO/main/scripts/setup-ec2-ssm.sh>
chmod +x setup-ec2-ssm.sh
./setup-ec2-ssm.sh i-INSTANCE-ID
```

## Example

```
./setup-ec2-ssm.sh i-00b4cbe3cd458dc3f
```

# ✅ 4. One‑liner execution (no file saved)

```
curl -s <https://raw.githubusercontent.com/YOUR-USER/YOUR-REPO/main/scripts/setup-ec2-ssm.sh> | bash -s -- i-INSTANCE-ID
```

# Example

```
curl -s <https://raw.githubusercontent.com/pitfunie/layer3-soc-platform/main/scripts/setup-ec2-ssm.sh> | bash -s -- i-00b4cbe3cd458dc3f
```

# 🔥 Optional: Add a CloudShell alias for your whole team

## Drop this into ~/.bashrc inside CloudShell

```
alias setup-ssm='curl -s <https://raw.githubusercontent.com/YOUR-USER/YOUR-REPO/main/scripts/setup-ec2-ssm.sh> | bash -s --'
```

## Then your team can run

```
setup-ssm i-INSTANCE-ID
```
