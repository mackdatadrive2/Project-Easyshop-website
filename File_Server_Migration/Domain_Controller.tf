
# --- Find latest Windows Server 2022 Base AMI (public) ---
data "aws_ami" "win2022" {
  most_recent = true
  owners      = ["801119661308"] # Amazon public AMI owner

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# --- Security Group for Domain Controller (RDP restricted + AD ports internal) ---
resource "aws_security_group" "dc_sg" {
  name        = "win2022-dc-sg"
  description = "RDP + AD DS/DNS internal"
  vpc_id      = aws_vpc.migration.id

  # RDP from admin CIDR (your IP)
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # DNS
  ingress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Kerberos
  ingress {
    description = "Kerberos TCP"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "Kerberos UDP"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  # LDAP / LDAPS
  ingress {
    description = "LDAP"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "LDAP UDP"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Global Catalog
  ingress {
    description = "Global Catalog"
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "Global Catalog SSL"
    from_port   = 3269
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # SMB + Netlogon + RPC Endpoint Mapper
  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "NetBIOS (optional)"
    from_port   = 139
    to_port     = 139
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "RPC Endpoint Mapper"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Dynamic RPC ports (AD uses dynamic range; you can tighten this by configuring fixed RPC range)
  ingress {
    description = "Dynamic RPC"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "win2022-dc-sg" })
}


# --- Windows 2022 Domain Controller in PUBLIC subnet (demo parity) ---
resource "aws_instance" "win2022_dc" {
  ami                         = data.aws_ami.win2022.id
  instance_type               = var.dc_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.dc_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  
  user_data = file("${path.module}/userdata_dc_win2022.ps1")

  tags = merge(var.tags, { Name = "Win2022-DomainController" })
}

output "dc_public_ip" {
  value = aws_instance.win2022_dc.public_ip
}

output "dc_private_ip" {
  value = aws_instance.win2022_dc.private_ip
}