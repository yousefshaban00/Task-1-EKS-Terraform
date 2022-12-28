# Input Variables - AWS IAM OIDC Connect Provider


# EKS OIDC ROOT CA Thumbprint
variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

#https://marcincuber.medium.com/amazon-eks-with-oidc-provider-iam-roles-for-kubernetes-services-accounts-59015d15cb0c