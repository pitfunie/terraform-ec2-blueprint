
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
