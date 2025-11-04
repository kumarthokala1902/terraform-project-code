provider "aws" {
    region = "us-west-2"
}

module "new_instance"{

    source = "./new_folder"
    ami_id = "ami-0bdd88bd06d16ba03"
    instance_type = "t2.micro"
    subnet_id = "subnet-08e03c96595840c3d"

  
}