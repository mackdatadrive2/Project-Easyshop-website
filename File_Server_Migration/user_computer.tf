# --- Find latest Windows Server 2019 Base AMI (public) ---
data "aws_ami" "windowsworkstation" {
  most_recent = true
  owners      = ["801119661308"] # Amazon public AMI owner

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# --- Security Group for File Server ---
resource "aws_security_group" "user-server_sg" {
  name        = "win2019-user-server-sg"
  description = "RDP + SMB internal"
  vpc_id      = aws_vpc.migration.id

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "win2019-user-server-sg" })
}


# --- Windows 2019 File Server in PUBLIC subnet (demo parity) ---
resource "aws_instance" "win2019_User-server" {
  ami                         = data.aws_ami.win2019.id
  instance_type               = var.fs_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.fs_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name

  user_data = file("${path.module}/userdata_fileserver_win2019.ps1")

  
# ✅ Root volume 30 GB
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.tags, { Name = "Win2019-user-Server" })
}

output "user-server_public_ip" {
  value = aws_instance.win2019_fileserver.public_ip
}

output "user-server_private_ip" {
  value = aws_instance.win2019_fileserver.private_ip
}