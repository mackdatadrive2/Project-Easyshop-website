data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # use var.azs if provided, otherwise take first two available AZs in the region
  selected_azs = length(var.azs) == 2 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 2)

  name_prefix = "Migration"
  vpc_name    = "Migration VPC"
}

# -----------------------
# VPC
# -----------------------
resource "aws_vpc" "migration" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = local.vpc_name
  })
}

# -----------------------
# Internet Gateway (one per VPC)
# -----------------------
resource "aws_internet_gateway" "migration" {
  vpc_id = aws_vpc.migration.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-IGW"
  })
}

# -----------------------
# Public Subnets (2) across 2 AZs
# -----------------------
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.migration.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-Public-Migration-${local.selected_azs[count.index]}"
    Tier = "public"
  })
}

# -----------------------
# Private Subnets (2) across 2 AZs
# -----------------------
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.migration.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.selected_azs[count.index]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-Private-${local.selected_azs[count.index]}"
    Tier = "private"
  })
}

# -----------------------
# Route Tables
#   - Public RT routes 0.0.0.0/0 to IGW
#   - Private RT is local-only (no NAT requested)
# -----------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.migration.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-Public-RT"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.migration.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.migration.id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-Private-RT"
  })
}

resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}