variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Tag name for the EC2 instance"
  type        = string
  default     = "linux-demo-ec2"
}
