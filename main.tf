# EPAM Masters Program: Cloud & DevOps
# Module 2. Infrastructure as Code. Terraform.
# Homework


terraform {
  required_version = ">=1.0"
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}


provider "aws" {
  region = var.region
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "epam-homework-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_ipv6        = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


resource "aws_security_group" "lb_public_access" {
  name   = "lb-public-access"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
}


resource "aws_security_group" "ec2_lb_access" {
  name   = "ec2-lb-access"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb_public_access.id
    ]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


resource "aws_instance" "app" {
  count         = var.instances_per_subnet * length(module.vpc.private_subnets)
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[count.index % length(module.vpc.private_subnets)]

  vpc_security_group_ids = [
    aws_security_group.ec2_lb_access.id
  ]
  associate_public_ip_address = false

  user_data = <<-EOF
        #!/bin/sh
        apt-get update
        apt-get install -y nginx-light
        echo "Hello! I'm instance <b>app-${count.index}</b>" > /var/www/html/index.html
    EOF

  tags = {
    "Name" = "app-${count.index}"
  }

  depends_on = [
    module.vpc.natgw_ids
  ]
}


resource "aws_elb" "app" {
  name    = "epam-homework-elb"
  subnets = module.vpc.public_subnets

  security_groups = [
    aws_security_group.lb_public_access.id
  ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 10
  }

  instances = [for i in aws_instance.app : i.id]

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 300
}
