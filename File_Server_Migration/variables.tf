variable "admin_cidr" {
  description = "Your public IP CIDR for RDP access (e.g., 1.2.3.4/32)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR, used to allow internal AD/SMB traffic"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dc_instance_type" {
  description = "Instance type for Domain Controller"
  type        = string
  default     = "t3.large"
}

variable "fs_instance_type" {
  description = "Instance type for File Server"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}



variable "azs" {
  description = "Two AZs to spread subnets across"
  type        = list(string)
  # Example for us-east-1; adjust if you want
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for 2 public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for 2 private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}


variable "name_prefix" {
  description = "Prefix for naming IAM resources"
  type        = string
  default     = "migration"
}
