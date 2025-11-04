variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_name" {
  type    = string
  default = "olake-minikube-vm"
}

variable "instance_type" {
  type    = string
  default = "t3.xlarge" 
}

variable "ami_id" {
  type    = string
  description = "Ubuntu 22.04 AMI - use SSM param or override per region"
  default = "ami-0ecb62995f68bb549"
}

variable "ssh_key_name" {
  type = string
  
}

variable "tfstate_bucket" {
  type = string
}
