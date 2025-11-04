provider "aws" {
      
    region = "us-east-1"
}

resource "aws_instance" "new_instance" {
    ami = "var.ami_id"
    instance_type = "var.instance_type"
    subnet_id = "var.subnet_id"
}
