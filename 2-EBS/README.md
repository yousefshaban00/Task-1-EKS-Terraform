##  Setup a Kubernetes cluster on AWS EKS infrastructure


all info about architect Design:

![Alt text](./Capture.PNG)


###  install EKS EBS CSI Driver as a AWS-EKS Add-On

The EBS Container Storage Interface (CSI) driver is a plugin for the Kubernetes Container Storage Interface (CSI) that allows you to use Amazon Elastic Block Store (EBS) volumes as persistent storage for your applications running on Amazon Elastic Container Service for Kubernetes (EKS).

With the EBS CSI driver, you can create and manage EBS volumes directly from your Kubernetes application, and use them as persistent storage for your application's data. The EBS CSI driver handles the creation and attachment of the EBS volumes to the worker nodes in your EKS cluster, and exposes the volumes as a native Kubernetes resource called a Persistent Volume (PV).

To use the EBS CSI driver in your EKS cluster, you will need to install the driver on your cluster and create a StorageClass resource that specifies the configuration for the EBS volumes that you want to use.

* **The EBS Container Storage Interface (CSI) add-on is a feature**

The EBS Container Storage Interface (CSI) add-on is a feature of Amazon Elastic Container Service for Kubernetes (EKS) that allows you to use Amazon Elastic Block Store (EBS) volumes as persistent storage for your applications running on EKS.

The EBS CSI add-on is based on the Kubernetes Container Storage Interface (CSI) and includes the EBS CSI driver, which is a plugin that allows you to create and manage EBS volumes directly from your Kubernetes application. The EBS CSI add-on also includes the EBS FlexVolume driver, which allows you to use EBS volumes as persistent storage for applications that are not natively CSI-aware.

To use the EBS CSI add-on in your EKS cluster, you will need to enable the add-on in your cluster and install the drivers on your worker nodes. You can then create and manage EBS volumes as persistent storage for your applications using the kubectl command-line tool or the AWS Management Console.



* **Remote State Data Source**
In Terraform, a remote state data source is a way to access the state information of a Terraform configuration that is stored remotely, such as in a Terraform Cloud workspace or an Amazon S3 bucket.

To use a remote state data source in your Terraform configuration, you will need to specify the terraform block and the data block in your configuration file.


**Define Remote State Data Source:** `c2-remote-state-datasource.tf`
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

**Create ebs-csi-datasources:** `c4-01-ebs-csi-datasources.tf`
```
# Datasource: AWS Caller Identity
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Datasource: EBS CSI IAM Policy get from EBS GIT Repo (latest)
data "http" "ebs_csi_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

output "ebs_csi_iam_policy" {
  value = data.http.ebs_csi_iam_policy.response_body
}


```


**Create ebs-csi-iam-policy-and-role Terraform Configuration:** `c4-02-ebs-csi-iam-policy-and-role.tf`
```
#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn

# Resource: Create EBS CSI IAM Policy 
resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "${local.name}-AmazonEKS_EBS_CSI_Driver_Policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  policy = data.http.ebs_csi_iam_policy.response_body
}

output "ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.ebs_csi_iam_policy.arn 
}

# Resource: Create IAM Role and associate the EBS IAM Policy to it
resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "${local.name}-ebs-csi-iam-role"

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
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }        

      },
    ]
  })

  tags = {
    tag-key = "${local.name}-ebs-csi-iam-role"
  }
}

# Associate EBS CSI IAM Policy to EBS CSI IAM Role
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn 
  role       = aws_iam_role.ebs_csi_iam_role.name
}

output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM Role ARN"
  value = aws_iam_role.ebs_csi_iam_role.arn
}



```


**Create ebs-csi-addon-install Terraform Configuration:** `c4-03-ebs-csi-addon-install.tf`
```
# Resource: EBS CSI Driver AddOn
# Install EBS CSI Driver using EKS Add-Ons (aws_eks_addon)
resource "aws_eks_addon" "ebs_eks_addon" {
  depends_on = [ aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach]
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_id 
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn 
}

/*
service_account_role_arn - (Optional) The Amazon Resource Name (ARN) of an existing IAM role to bind to the add-on's service account. The role must be assigned the IAM permissions required by the add-on.
 If you don't specify an existing IAM role, then the add-on uses the permissions assigned to the node IAM role. 
 */
 
```


**Create ebs-csi-outputs Terraform Configuration:** `c4-04-ebs-csi-outputs.tf`
```
# EKS AddOn - EBS CSI Driver Outputs 
output "ebs_eks_addon_arn" {
  description = "EKS AddOn - EBS CSI Driver ARN"
  value = aws_eks_addon.ebs_eks_addon.arn
}
output "ebs_eks_addon_id" {
  description = "EKS AddOn - EBS CSI Driver ID"
  value = aws_eks_addon.ebs_eks_addon.id 
}

```







