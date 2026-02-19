# Local values block
# Used to define reusable variables inside the Terraform configuration
locals {

  # AWS region where all resources will be created
  region = "eu-west-1"

  # Name used for tagging and identifying resources
  name   = "Jenkins"

  # CIDR block for the VPC
  vpc_cidr = "10.0.0.0/16"

  # Availability Zones used for high availability
  azs  = ["eu-west-1a", "eu-west-1b"]

  # CIDR ranges for public subnets
  # Typically used for Load Balancers, NAT Gateway, Bastion Host
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # CIDR ranges for private subnets
  # Typically used for EKS worker nodes, databases, backend services
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  # Common tags applied to all AWS resources
  tags = {
    example = local.name
  }
}

# AWS provider configuration
# Tells Terraform which cloud provider to use
provider "aws" {

  # AWS region is dynamically taken from local values
  region = local.region
}
