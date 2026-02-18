data "aws_ami" "os_image" {                          # Data source: queries AWS to find an AMI (does NOT create a resource)
  most_recent = true                                # Always selects the latest AMI that matches the filters
  owners      = ["amazon"]                          # Restricts search to official AMIs published by Amazon
  
  filter {                                          # First filter block to narrow down AMI results
    name   = "state"                                # Filter on the AMI state attribute
    values = ["available"]                          # Ensures the AMI is available and can be launched
  }                                     

  filter {                                          # Second filter block to match AMI by name pattern
    name   = "name"                                 # Filter using the AMI name field
    values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]  # Selects Ubuntu 24.04 LTS, HVM virtualization, GP3 storage, x86_64
  }
}

resource "aws_key_pair" "deployer" {                # Creates an EC2 Key Pair resource in AWS for SSH access
  key_name   = "terra-automate-key"                  # Name of the key pair as it will appear in AWS
  public_key = file("terra-key.pub")                 # Reads the local public SSH key and uploads it to AWS
}

resource "aws_security_group" "allow_user_to_connect" {   # Security Group acting as a virtual firewall
  name        = "allow TLS"                          # Name of the security group in AWS
  description = "Allow user to connect"              # Description explaining the purpose of the security group
  vpc_id      = module.vpc.vpc_id                    # Associates the security group with the VPC created by the VPC module

  dynamic "ingress" {                                # Dynamic block to generate multiple ingress rules programmatically
    for_each = [                                     # List of ingress rule definitions
      { description = "port 22 allow",  from = 22,   to = 22,   protocol = "tcp", cidr = ["0.0.0.0/0"] },   # Allows SSH from anywhere
      { description = "port 80 allow",  from = 80,   to = 80,   protocol = "tcp", cidr = ["0.0.0.0/0"] },   # Allows HTTP traffic
      { description = "port 443 allow", from = 443,  to = 443,  protocol = "tcp", cidr = ["0.0.0.0/0"] },   # Allows HTTPS traffic
      { description = "port 8080 allow",from = 8080, to = 8080, protocol = "tcp", cidr = ["0.0.0.0/0"] }    # Allows Jenkins access
    ]

    content {                                       # Defines the actual ingress rule content per iteration
      description = ingress.value.description       # Uses the description from the current rule
      from_port   = ingress.value.from              # Starting port number for the rule
      to_port     = ingress.value.to                # Ending port number for the rule
      protocol    = ingress.value.protocol          # Network protocol (TCP)
      cidr_blocks = ingress.value.cidr              # Allowed CIDR ranges (0.0.0.0/0 = open to internet)
    }
  }

  egress {                                          # Outbound rule allowing traffic to leave the instance
    description = "Allow all outbound traffic"      # Description of outbound rule
    from_port   = 0                                 # Start port (0 means all ports)
    to_port     = 0                                 # End port (0 means all ports)
    protocol    = "-1"                              # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]                     # Allows outbound traffic to anywhere
  }

  tags = {                                          # Tags applied to the security group
    Name = "mysecurity"                             # Tag name used for identification and billing
  }
}

resource "aws_instance" "testinstance" {            # Creates an EC2 instance
  ami           = data.aws_ami.os_image.id           # Uses the dynamically fetched Ubuntu 24.04 AMI ID
  instance_type = var.instance_type.id               # EC2 instance size taken from variables.tf
  key_name      = aws_key_pair.deployer.key_name     # Attaches the SSH key pair for login
  vpc_security_group_ids = [aws_security_group.allow_user_to_connect.id]        # Applies the security group
  subnet_id     = module.vpc.public_subnets[0]       # Launches instance in the first public subnet
  user_data     = file("${path.module}/install tools.sh") # Runs bootstrap script on first boot
  tags = {                                          # Tags for the EC2 instance
    Name = "Jenkins-Automate"                        # Instance name shown in AWS Console
  }

  root_block_device {                               # Configuration for the root EBS volume
    volume_size = 20                                # Sets root disk size to 20 GB
    volume_type = "gp3"                             # Uses GP3 for better performance and lower cost
  }
}

resource "aws_eip" "jenkins_server_ip" {             # Allocates and associates an Elastic IP
  instance = aws_instance.testinstance               # Binds the Elastic IP to the EC2 instance
  domain   = "vpc"                                   # Specifies the EIP is for use within a VPC
}
