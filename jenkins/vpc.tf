# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "vpc_jenkins" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# ----------------------------
# Availability Zones
# ----------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# ----------------------------
# Internet Gateway
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_jenkins.id
}

# ----------------------------
# Public Subnets (2)
# ----------------------------
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc_jenkins.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

# ----------------------------
# Route Table
# ----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# ----------------------------
# Route Table Association
# ----------------------------
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}