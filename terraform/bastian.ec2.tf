resource "aws_security_group" "allow_user_bastion" {              # Creates a security group to control inbound/outbound traffic for the bastion host

  name        = "bastion_host_sg"                                  # Name of the security group as it appears in AWS
  description = "allow user to connect"                            # Description explaining the purpose of this security group
  vpc_id     = module.vpc.vpc_id                                   # Associates the security group with the VPC created by the VPC module

  dynamic "ingress" {                                              # Dynamic block to create multiple ingress rules programmatically
    for_each = [                                                    # List of ingress rule definitions to loop over
      { description = "port 22 allow",  from = 22,  to = 22,  protocol = "tcp", cidr = ["0.0.0.0/0"] },   # Allow SSH access from anywhere
      { description = "port 80 allow",  from = 80,  to = 80,  protocol = "tcp", cidr = ["0.0.0.0/0"] },   # Allow HTTP access from anywhere
      { description = "port 443 allow", from = 443, to = 443, protocol = "tcp", cidr = ["0.0.0.0/0"] }    # Allow HTTPS access from anywhere
    ]

    content {                                                      # Defines how each ingress rule is created using loop values
      description = ingress.value.description                      # Uses the description field from the current loop item
      from_port   = ingress.value.from                             # Starting port number for the ingress rule
      to_port     = ingress.value.to                               # Ending port number for the ingress rule
      protocol    = ingress.value.protocol                         # Network protocol used (TCP)
      cidr_blocks = ingress.value.cidr                             # CIDR ranges allowed to access the port
    }
  }

  egress {                                                         # Outbound (egress) traffic rules
    description = "Allow all outbound traffic"                     # Explains that all outbound traffic is permitted
    from_port   = 0                                                # Starting port (0 used with -1 protocol)
    to_port     = 0                                                # Ending port (0 used with -1 protocol)
    protocol    = "-1"                                             # -1 means allow all protocols (TCP, UDP, ICMP, etc.)
    cidr_blocks = ["0.0.0.0/0"]                                    # Allows outbound traffic to any destination
  }

  tags = {                                                         # Tags for identifying and managing the security group
    Name = "bastion_security"                                      # Name tag shown in AWS console
  }
}




resource "aws_instance" "bastion_host" {                           # Creates an EC2 instance that acts as a Bastion (jump) host

  ami           = data.aws_ami.os_image.id                          # AMI ID fetched dynamically using a data source (latest OS image)
  instance_type = var.instace_type                                  # EC2 instance type (taken from variable, e.g., t3.medium)
  key_name      = aws_key_pair.deployer_key.key_name                # SSH key pair used to securely log in to the instance

  vpc_security_group_ids = [aws_security_group.allow_user_bastion.id] # Attaches the bastion security group to this EC2 instance
  subnet_id              = module.vpc.public_subnets[0]             # Launches the instance in the first public subnet of the VPC

  user_data = file("${path.module}/bastion_user_data.sh")           # Runs a startup script on instance boot (install tools, hardening, etc.)

  tags = {                                                          # Tags applied to the EC2 instance
    Name = "Bastian-Host"                                           # Name shown in AWS console (typo: should be Bastion-Host)
  }

  root_block_device {                                               # Configuration for the root EBS volume
    volume_size = 20                                                # Root disk size in GB
    volume_type = "gp3"                                             # gp3 volume type (better performance & cheaper than gp2)
  }
}
