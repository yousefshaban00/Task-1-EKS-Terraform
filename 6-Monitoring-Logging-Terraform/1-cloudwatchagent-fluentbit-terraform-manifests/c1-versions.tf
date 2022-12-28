# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
     }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }    
    http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }     
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }     
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aws-eks-terraform"
    key    = "dev/eks-cloudwatch-agent/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-eks-cloudwatch-agent"    
  }     
}

