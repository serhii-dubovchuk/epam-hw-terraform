variable "region" {
  description = "AWS Default Region"
  type        = string
}


variable "ami_id" {
  description = "ID of AMI that will be used by every EC2 instance"
  type        = string

  validation {
    condition     = length(var.ami_id) >= 12
    error_message = "AMI ID should contain at least 12 characters"
  }

  validation {
    condition     = startswith(var.ami_id, "ami-")
    error_message = "AMI ID should start with the 'ami-' prefix"
  }
}


variable "instances_per_subnet" {
  description = "Amount of instances to be created in each subnet"
  type        = number

  validation {
    condition     = var.instances_per_subnet > 0
    error_message = "Amount of instances must be a positive non-zero integer"
  }
}
