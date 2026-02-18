variable "aws_region"  {
    description = "aws region where all resources will be provisined"
    default     = "eu-west-1"
}


variable "ami_id" {
    description = "ami id for the EC2 instances"
    default     = "ami-085f9c64a9b75eed5" 
}

variable "instace_type" {
    description = "Instance type for the EC2 instances"
    default     = "t3.medium"
}

variable "my_environment" {
    description = "Instance type for the EC2 instances"
    default     = "dev"
}