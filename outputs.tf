output "ami_id" {
  description = "ID of AMI used for the creation of EC2 instances"
  value       = var.ami_id
}


output "instances_per_subnet" {
  description = "Amount of EC2 instances to create per each subnet"
  value       = var.instances_per_subnet
}
