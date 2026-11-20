variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "idevify-ec2-key"
}

variable "allowed_ssh_cidr" {
  description = "47.11.20.47/32"
  type        = string
}