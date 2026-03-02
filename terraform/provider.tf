locals {                                           # Define local values that act like constants and can be reused across the Terraform configuration

  region = "eu-west-1"                             # AWS region where all infrastructure resources will be created (Ireland region)

  name   = "dock-eks-cluster"                      # Base name used for identifying and tagging AWS resources such as VPC, subnets, and EKS cluster

  vpc_cidr = "10.0.0.0/16"                         # CIDR block for the VPC, providing up to 65,536 private IP addresses

  azs  = ["eu-west-1a", "eu-west-1b"]              # List of Availability Zones to distribute resources for high availability and fault tolerance

  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]  # CIDR ranges for public subnets; these subnets have routes to an Internet Gateway

  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"] # CIDR ranges for private subnets; used for internal workloads like EKS worker nodes

  tags = {                                         # Common tag map to apply consistent metadata across AWS resources
    example = local.name                           # Tag value referencing the local name to identify resource ownership/project
  }
}

provider "aws" {                                   # Configure the AWS provider so Terraform knows how to communicate with AWS APIs
  region = local.region                            # Sets the AWS region dynamically using the local variable defined above
}


### This Terraform configuration defines reusable local variables for networking and tagging 
### and configures the AWS provider to deploy all AWS resources consistently in a single region.