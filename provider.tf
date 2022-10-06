provider "aws" {
    region = "ap-southeast-1"
    alias = "sea_region"
}

provider "aws" {
    region = "ap-south-1"
    alias = "in_region"
}

provider "aws" {
    region = "us-east-1"
    alias = "us_region"
}

provider "aws" {
    region = "eu-north-1"
    alias = "eu_region"
}
