# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
     }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aws-eks-terraform"
    key    = "dev/ebs-addonn/terraform.tfstate"
    region = "us-east-1" 
   
    # For State Locking
    dynamodb_table = "dev-ebs-addon"
       
  }     
}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}