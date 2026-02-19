terraform {

  # Configure S3 as the remote backend for Terraform state
  backend "s3" {

    # Name of the S3 bucket where the Terraform state file is stored
    # The bucket must already exist in AWS
    bucket = "terraform-s3-backend-terraform"

    # Name (path) of the state file inside the S3 bucket
    # This will create an object like:
    # s3://terraform-s3-backend-tws-hackathon/backend.locking
    key = "backend.locking"

    # AWS region where the S3 bucket is located
    region = "us-east-1"

    # Enables S3-based state locking using a lock file (.tflock)
    # Prevents multiple users from running terraform apply at the same time
    use_lockfile = true
  }
}
