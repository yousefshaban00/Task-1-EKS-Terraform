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
 