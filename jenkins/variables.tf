variable "aws_region"  {
    description = "aws region where all resources will be provisined"
    default     = "eu-west-1"
}


variable "instace_type" {
    description = "Instance type for the EC2 instances"
    default     = "t3.micro"
}

variable "my_environment" {
    description = "Instance type for the EC2 instances"
    default     = "dev"
}