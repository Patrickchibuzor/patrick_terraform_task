variable "region" {
  description = "The AWS region to deploy in"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "backend_instance_type" {
  description = "Instance type for backend servers"
  type        = string
}

variable "frontend_instance_type" {
  description = "Instance type for frontend servers"
  type        = string
}


variable "key_name" {
  description = "Instance type for backend servers"
  type        = string
}

variable "iam_user" {
  description = "Instance type for frontend servers"
  type        = string
}
variable "Access_key" {
  description = "Instance type for frontend servers"
  type        = string
}
variable "Secret_key" {
  description = "Instance type for frontend servers"
  type        = string
}
