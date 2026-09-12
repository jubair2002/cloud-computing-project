terraform {
  backend "s3" {
    bucket  = "shophub-tfstate"
    key     = "shophub/test/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # Create this DynamoDB table manually if you want a lock table:
    # dynamodb_table = "shophub-tfstate-lock"
  }
}

# Notes:
# 1. Create the S3 bucket manually before running terraform init.
# 2. Keep the bucket name region-specific and globally unique.
# 3. Enable versioning and server-side encryption on the bucket yourself.
# 4. The bucket here is for Terraform remote state only, not for application data.
