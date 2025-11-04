data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "olake_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH and OLake UI"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict in prod
    description = "SSH"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OLake UI"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.instance_name}-sg"
    env   = "dev"
    owner = "student"
  }
}

resource "aws_instance" "olake_vm" {
  ami             = var.ami_id
  instance_type   = var.instance_type

  subnet_id       = element(data.aws_subnets.default.ids, 0)

  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.olake_sg.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  
  user_data = file("${path.module}/cloud-init.yaml")

  tags = {
    Name    = var.instance_name
    project = "olake"
    env     = "dev"
  }
}

provider "helm" {
  kubernetes {
    config_path = "/home/kumar/.kube/config"

  }
}

resource "helm_release" "olake" {
  name       = "olake"
  repository = "https://datazip-inc.github.io/olake-helm"
  chart      = "olake"
  version    = "" 

  values = [
    file("${path.module}/helm_values.yaml")
  ]

  depends_on = [aws_instance.olake_vm]
}

