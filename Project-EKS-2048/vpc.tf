module "vpc" {                                  # Define a Terraform module named "vpc"

  source  = "terraform-aws-modules/vpc/aws"     # Source of the VPC module from Terraform Registry
  version = "5.18.1"                            # Lock the module version for consistency

  name = local.name                             # Name of the VPC (used for tagging and identification)
  cidr = local.vpc_cidr                         # CIDR block for the VPC network range

  azs             = local.azs                   # Availability Zones for subnet distribution
  public_subnets  = local.public_subnets        # CIDR blocks for public subnets
  private_subnets = local.private_subnets       # CIDR blocks for private subnets

  enable_nat_gateway     = true                 # Enable NAT Gateway for outbound internet access
  single_nat_gateway     = true                 # Create only one NAT Gateway to reduce cost
  one_nat_gateway_per_az = false                # Disable one NAT Gateway per AZ

  public_subnet_tags = {                        # Tags applied to public subnets
    "kubernetes.io/role/internal-elb" = "1"     # Marks subnet for Kubernetes internal load balancers
  }

  private_subnet_tags = {                       # Tags applied to private subnets
    "kubernetes.io/role/internal-elb" = "1"     # Marks subnet for Kubernetes internal load balancers
  }

  map_public_ip_on_launch = true                # Auto-assign public IP to instances in public subnets
}




### This module creates a highly available AWS VPC with public and private subnets,
### NAT Gateway for outbound internet access, and Kubernetes-compatible subnet tagging.