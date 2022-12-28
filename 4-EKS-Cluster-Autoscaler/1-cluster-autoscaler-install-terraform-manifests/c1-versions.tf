# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
     }
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }      
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aws-eks-terraform"
    key    = "dev/eks-cluster-autoscaler/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-eks-cluster-autoscaler"    
  }     
}

# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}

# Terraform HTTP Provider Block
provider "http" {
  # Configuration options
}