variable "aws_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
  default     = "us-west-1"
}

#------------------------------#

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

#------------------------------#

variable "public_subnet_1_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = string
}

#------------------------------#

variable "public_subnet_2_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = string
}

#------------------------------#

variable "private_subnet_1_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = string
}

#------------------------------#

variable "private_subnet_2_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = string
}

#------------------------------#

variable "AZ_1" {
  description = "values for availability zones"
  type        = string
}

#------------------------------#

variable "AZ_2" {
  description = "values for availability zones"
  type        = string
}

#------------------------------#

variable "cidrs" {
  description = "CIDR block for the route table"
  type        = string
}

#------------------------------#

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

#------------------------------#
variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

#------------------------------#
variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}
#------------------------------#
variable "db_username" {
  description = "Username for the RDS"
  type        = string
}
#------------------------------#
variable "db_password" {
  description = "Password for the RDS"
  type        = string
  sensitive   = true
}
#------------------------------#
variable "db_name" {
  description = "Database name"
  type        = string
}
#------------------------------#
variable "chami" {
  description = "AMI ID for the Jenkins instance"
  type        = string
  
}
#------------------------------#