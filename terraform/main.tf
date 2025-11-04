# VPC & subnet - to keep it simple we use the default VPC
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
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
    Name = "${var.instance_name}-sg"
    env  = "dev"
    owner = "student"
  }
}

# Key pair assumed to be created in AWS console or via Terraform (not shown)
resource "aws_instance" "olake_vm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(data.aws_subnet_ids.default.ids, 0)
  key_name      = var.ssh_key_name
  security_groups = [aws_security_group.olake_sg.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  # Option B: use cloud-init user data to bootstrap Minikube and deps (recommended)
  user_data = file("${path.module}/cloud-init.yaml")

  tags = {
    Name = var.instance_name
    project = "olake"
    env     = "dev"
  }
}

output "instance_id" {
  value = aws_instance.olake_vm.id
}

output "public_ip" {
  value = aws_instance.olake_vm.public_ip
}




provider "helm" {
  kubernetes {
    config_path = "/home/ubuntu/.kube/config" # path on machine running Terraform
  }
}

resource "helm_release" "olake" {
  name       = "olake"
  repository = "https://datazip-inc.github.io/olake-helm"
  chart      = "olake"
  version    = "" # optional pin

  values = [
    file("${path.module}/helm_values.yaml")
  ]

  depends_on = [aws_instance.olake_vm]
}



#terraform apply -var="ssh_key_name=my-key" -var="tfstate_bucket=terraform-state-olake"
