# --- Find latest Windows Server 2016 Base AMI (public) ---
data "aws_ami" "win2016" {
  most_recent = true
  owners      = ["801119661308"] # Amazon public AMI owner

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Security Group for RDP + SQL (restricted to your IP) ---
resource "aws_security_group" "win_sql_sg" {
  name        = "win2016-sql-express-sg"
  description = "RDP + SQL access"
  vpc_id      = aws_vpc.migration.id

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Optional: allow SQL from your IP (remove if you want local-only SQL)
  ingress {
    description = "SQL Server"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "win2016-sql-express-sg" })
}

# --- Windows EC2 instance in the PUBLIC subnet you created earlier ---
resource "aws_instance" "win2016_sql" {
  ami                         = data.aws_ami.win2016.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id   # ✅ USES YOUR PUBLIC SUBNET
  vpc_security_group_ids      = [aws_security_group.win_sql_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true  # safe for public subnet

  user_data = file("${path.module}/userdata_sql_express.ps1")

  tags = merge(var.tags, { Name = "Win2016-SQLExpress" })
}

output "win_instance_public_ip" {
  value = aws_instance.win2016_sql.public_ip
}