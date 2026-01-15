```
# This file is part of the terraform-ec2-blueprint project
# Copyright (C) 2026  Michael WyCliff Williams

#

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version

#

# This program is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details

#

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>
```

#### 🔐 Bonus tip: GitHub raw URLs are public

You’re building a clean, reusable automation system — and it’s looking sharp.

Anyone with the link can run your script. If you want to restrict access later, you can:

- Make the repo private
- Use GitHub authentication
- Move sensitive logic into IAM‑protected Terraform modules

## Let me know if you want to

- Generate a README section for this
- Add a GitHub Action to auto‑validate the scaffold
- Modularize the EC2 logic into `modules/ec2-linux-demo` next

---

# 🔁 Local workflow

## Create or edit your script

```bash
touch setup-terraform-scaffold.sh
code setup-terraform-scaffold.sh
```

## Make it executable

```bash
chmod +x setup-terraform-scaffold.sh
```

## Push to GitHub

```bash
git add setup-terraform-scaffold.sh
git commit -m "Add Terraform scaffold script"
git push origin main
```

---

# 🌍 Anywhere else (CloudShell, new machine, teammate’s laptop)

## Clone your repo

```bash
git clone https://github.com/pitfunie/layer3-soc-platform.git
cd layer3-soc-platform/script
```

## Make it executable

```bash
chmod +x setup-terraform-scaffold.sh
```

## Run it

```bash
./setup-terraform-scaffold.sh
```

## Or run it directly from GitHub (no clone needed)

```bash
curl -s https://raw.githubusercontent.com/pitfunie/layer3-soc-platform/main/script/setup-terraform-scaffold.sh | bash
```
