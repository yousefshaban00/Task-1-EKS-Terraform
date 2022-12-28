# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
     }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }     
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aws-eks-terraform"
    key    = "dev/dev-ebs-sampleapp-demo/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-ebs-sampleapp-demo"    
  }    
}

