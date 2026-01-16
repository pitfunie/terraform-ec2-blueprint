
## new instannce webserver

```
module "web_server" {
  source = "./modules/ec2-linux-demo"
  instance_name = "web-server"
}
```

## new instances DB

```
module "db_server" {
  source = "./modules/ec2-linux-demo"
  instance_name = "database-server"
}
```

terraform-ec2-blueprint $ terraform plan > plan-output.txt
terraform-ec2-blueprint $ git add plan-output.txt
terraform-ec2-blueprint $ git commit -m "Proposed infrastructure changes"
Author identity unknown

*** Please tell me who you are.

Run

  git config --global user.email "<you@example.com>"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: empty ident name (for <cloudshell-user@ip-10-143-121-229.us-east-1.compute.internal>) not allowed
terraform-ec2-blueprint $ git push
Username for 'https://github.com': pitfunie
Password for 'https://pitfunie@github.com':
Everything up-to-date
terraform-ec2-blueprint $ git config --global credentials.helper store
terraform-ec2-blueprint $
