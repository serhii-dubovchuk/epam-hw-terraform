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
