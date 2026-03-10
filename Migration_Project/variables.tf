variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for Migration VPC"
  type        = string
  default     = "10.50.0.0/16"
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
  default     = ["10.50.1.0/24", "10.50.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for 2 private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.50.11.0/24", "10.50.12.0/24"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project = "Migration"
  }
}

variable "admin_cidr" {
  description = "Your public IP in CIDR for RDP/SQL e.g. 203.0.113.10/32"
  default = "0.0.0.0/0"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "key_name" {
  description = "Existing EC2 key pair name (needed to decrypt Windows admin password)"
  type        = string
  default = "dbserver"
}