# Local values block
# Used to define reusable variables inside the Terraform configuration
locals {
  # AWS region where all resources will be created
  region = "us-east-1"
}

# AWS provider configuration
# Tells Terraform which cloud provider to use
provider "aws" {
  # AWS region is dynamically taken from local values
  region = local.region
}
