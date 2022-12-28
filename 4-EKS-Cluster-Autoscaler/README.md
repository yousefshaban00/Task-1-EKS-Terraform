###  Setup a Kubernetes cluster on AWS EKS infrastructure

## EKS Cluster Auto Scaling

The Amazon Elastic Container Service for Kubernetes (EKS) Cluster Auto Scaling feature allows you to automatically scale the number of worker nodes in your EKS cluster based on the resource utilization of your applications.

To use the EKS Cluster Auto Scaler, you will need to enable the feature in your EKS cluster and specify the minimum and maximum number of worker nodes that you want to maintain in your cluster. The EKS Cluster Auto Scaler will then automatically add or remove worker nodes as needed to maintain the desired number of worker nodes based on the resource utilization of your applications.

You can enable the EKS Cluster Auto Scaler using the AWS Management Console, the AWS CLI, or the AWS SDKs.

To install the Cluster Autoscaler using Helm, you will need to have Helm and the necessary permissions to create resources on your cluster. You will also need to have the Cluster Autoscaler chart available in your Helm repository.

helm install autoscale/cluster-autoscaler \
  --name cluster-autoscaler \
  --namespace kube-system \
  --set awsRegion=<AWS region>,awsClusterName=<EKS cluster name>,awsVpcID=<VPC ID>,awsRoleARN=<IAM role ARN>


**Create Terraform Block Configuration:** `c1-versions.tf`

* **HTTP Data Source**
In Terraform, the http data source is a way to fetch data from a remote HTTP endpoint and use it in your Terraform configuration. The http data source can be used to retrieve data from APIs, web services, and other HTTP-based sources.

To use the http data source in your Terraform configuration, you will need to specify the data block and the http data source in your configuration file.


```
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
```


**Create remote-state-datasource Terraform Configuration:** `c2-remote-state-datasource.tf`
```
# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "aws-eks-terraform"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = var.aws_region
  }
}


```



**Create cluster-autoscaler-iam-policy-and-role Terraform Configuration:** `c4-01-cluster-autoscaler-iam-policy-and-role.tf`
```
# Resource: IAM Policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler_iam_policy" {
  name        = "${local.name}-AmazonEKSClusterAutoscalerPolicy"
  path        = "/"
  description = "EKS Cluster Autoscaler Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeInstanceTypes"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
})
}

# Resource: IAM Role for Cluster Autoscaler
## Create IAM Role and associate it with Cluster Autoscaler IAM Policy
resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  name = "${local.name}-cluster-autoscaler"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "cluster-autoscaler"
  }
}


# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.cluster_autoscaler_iam_policy.arn 
  role       = aws_iam_role.cluster_autoscaler_iam_role.name
}

output "cluster_autoscaler_iam_role_arn" {
  description = "Cluster Autoscaler IAM Role ARN"
  value = aws_iam_role.cluster_autoscaler_iam_role.arn
}

```



**Create cluster-autoscaler-helm-provider Terraform Configuration:** `c4-02-cluster-autoscaler-helm-provider.tf`
```
# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# HELM Provider
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
```



**Create cluster-autoscaler-install Terraform Configuration:** `c4-03-cluster-autoscaler-install.tf`
```
# Install Cluster Autoscaler using HELM

# Resource: Helm Release 
resource "helm_release" "cluster_autoscaler_release" {
  depends_on = [aws_iam_role.cluster_autoscaler_iam_role ]            
  name       = "${local.name}-ca"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  namespace = "kube-system"   

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_id
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.cluster_autoscaler_iam_role.arn}"
  }
 
}



```


**Create cluster-autoscaler-outputs Terraform Configuration:** `c4-04-cluster-autoscaler-outputs.tf`
```
# Helm Release Outputs
output "cluster_autoscaler_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.cluster_autoscaler_release.metadata
}

```





















