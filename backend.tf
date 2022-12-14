terraform {
  backend "s3" {
    bucket = "sk-state"
    key    = "demo/terraform-sk"
    dynamodb_table = "terraform-sk-lock"
    region = "us-east-1"
  }
   required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

