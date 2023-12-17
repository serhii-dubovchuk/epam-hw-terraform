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
        Terraform = "true"
        Environment = "dev"
    }
}
