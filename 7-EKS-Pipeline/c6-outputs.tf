# output "address" {
#   value = aws_elb.web.dns_name
# }

# output "code_build_project" {
#   value = aws_codebuild_project.containerAppBuild.arn
# }
# output "app_codepipeline_project" {
#   value = aws_codepipeline.app_pipeline.arn
# }

# output "python_app_codepipeline_project" {
#   value = aws_codepipeline.python_app_pipeline.arn
# }

# output "go_app_codepipeline_project" {
#   value = aws_codepipeline.go_app_pipeline.arn
# }



/*
error
│ Error message: 2 errors occurred:
│   * AccessDeniedException: User:
│ arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-41e341d8-ac5f-46f9-adf5-40e0dc2e862d
│ is not authorized to perform: dynamodb:PutItem on resource:
│ arn:aws:dynamodb:us-east-2:962490649366:table/dev-ebs-addon because no


│ Error: deleting S3 Bucket (my-artifact-store-iiiiiiiiiiiiiiii): BucketNotEmpty: The bucket you tried to delete is not empty       
│       status code: 409, request id: X5SK3WGCNNRJCB0P, host id: ehgRnxVJbHAHK8XDr2P3fBsy++xKKGiBesSCke2DQw4nsLZLfIU+9ZcS0nHqCq1V7HkZvEJLowI=

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Error refreshing state: AccessDenied: Access Denied
    status code: 403, request id: PV2M9MA1P5P3YQMX, host id: VH5PBX5iy6m9kDtNmnRcDjKU83R/gCC+ZI0HDzdEbcHFkiJAnsjJPEGMYGN01ohSUIJmK+LDCnY=

attach s3 access for servicerole of build projct

 Error: Error acquiring the state lock
│ 
│ Error message: 2 errors occurred:
│   * AccessDeniedException: User:
│ arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-aa86172e-46f4-411b-aee3-ad088802ba3d
│ is not authorized to perform: dynamodb:PutItem on resource:
│ arn:aws:dynamodb:us-east-2:962490649366:table/dev-efs-csi because no
│ identity-based policy allows the dynamodb:PutItem action
│   status code: 400, request id:
│ 7FTP2ECLFGN65MT72IAGPKB6VNVV4KQNSO5AEMVJF66Q9ASUAAJG
│   * AccessDeniedException: User:
│ arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-aa86172e-46f4-411b-aee3-ad088802ba3d
│ is not authorized to perform: dynamodb:GetItem on resource:
│ arn:aws:dynamodb:us-east-2:962490649366:table/dev-efs-csi because no
│ identity-based policy allows the dynamodb:GetItem action
│   status code: 400, request id:
│ 2RDMM2P4LO4F3BF59MJD02FJ3RVV4KQNSO5AEMVJF66Q9ASUAAJG


# name of S3 bucket + Policy for s3 and dynamo dB

#
Build specification reference for CodeBuild
https://github.com/awsdocs/aws-codebuild-user-guide/blob/main/doc_source/build-spec-ref.md


│ Error: error creating IAM Policy radio-dev-AmazonEKS_EFS_CSI_Driver_Policy: AccessDenied: 
User: arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-bffbcf98-0261-404f-ac7e-1ed507aef742
is not authorized to perform: iam:CreatePolicy on resource: policy radio-dev-AmazonEKS_EFS_CSI_Driver_Policy because no identity-based policy allows the iam:CreatePolicy action
│   status code: 403, request id: ef7a91f5-b196-4072-a6b7-469b10b34ab2


│ Error: failed creating IAM Role (radio-dev-efs-csi-iam-role): AccessDenied:
 User: arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-bffbcf98-0261-404f-ac7e-1ed507aef742 
 is not authorized to perform: iam:CreateRole on resource: arn:aws:iam::962490649366:role/radio-dev-efs-csi-iam-role because no identity-based policy allows the iam:CreateRole action
│   status code: 403, request id: e4a2ee67-5959-44c4-8225-8f5eae0754b7


│ Error: error creating IAM Policy radio-dev-AmazonEKS_EFS_CSI_Driver_Policy: EntityAlreadyExists: A policy called radio-dev-AmazonEKS_EFS_CSI_Driver_Policy already exists. Duplicate names are not allowed.
│   status code: 409, request id: 5464ee69-bb3d-4cc9-ae41-1700cb56ee4a
│ 
│   with aws_iam_policy.efs_csi_iam_policy,
│   on c4-02-efs-csi-iam-policy-and-role.tf line 2, in resource "aws_iam_policy" "efs_csi_iam_policy":
│    2: resource "aws_iam_policy" "efs_csi_iam_policy" {
│ 
╵
╷
│ Error: failed creating IAM Role (radio-dev-efs-csi-iam-role): EntityAlreadyExists: Role with name radio-dev-efs-csi-iam-role already exists.
│   status code: 409, request id: 704c2b80-a05f-4a1e-bb3d-4e859f737f1c
│ 
│   with aws_iam_role.efs_csi_iam_role,
│   on c4-02-efs-csi-iam-policy-and-role.tf line 14, in resource "aws_iam_role" "efs_csi_iam_role":
│   14: resource "aws_iam_role" "efs_csi_iam_role" {
│ 
if exist or create >> iqnore it 

aws_iam_role_policy_attachment.efs_csi_iam_role_policy_attach: Creation complete after 0s [id=radio-dev-efs-csi-iam-role-20230101144604420100000001]
╷
│ Error: Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with helm_release.efs_csi_driver,
│   on c4-04-efs-csi-install.tf line 4, in resource "helm_release" "efs_csi_driver":
│    4: resource "helm_release" "efs_csi_driver" {
│ 
 
 access EKS + aws cli + kubectl + authenticate with kubeconfig
[Container] 2023/01/01 15:48:55 Running command aws eks update-kubeconfig --name ${EKS_NAME} --region ${REGION}
Added new context arn:aws:eks:us-east-2:962490649366:cluster/radio-dev-ekstask1 to /root/.kube/config

 # Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 # SPDX-License-Identifier: MIT-0
 #
 # Permission is hereby granted, free of charge, to any person obtaining a copy of this
 # software and associated documentation files (the "Software"), to deal in the Software
 # without restriction, including without limitation the rights to use, copy, modify,
 # merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 # permit persons to whom the Software is furnished to do so.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 # PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 # SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 #  - terraform -chdir=./2-EBS/1-EBS-addon-terraform/ init
 # terraform -chdir=./2-EBS/1-EBS-addon-terraform/ apply -auto-approve

version: 0.2

phases:

  pre_build:
    commands:
     - echo Set parameter
     - REGION=us-east-2
     - AWS_ACCOUNTID=962490649366
     #- COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1–7)
    # - IMAGE_TAG=${COMMIT_HASH:=latest}
     - EKS_NAME=radio-dev-ekstask1
     - apt-get update
     - apt install -y awscli
     -  curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
     - chmod +x ./aws-iam-authenticator
     - mkdir -p ~/bin && cp ./aws-iam-authenticator ~/bin/aws-iam-authenticator && export PATH=~/bin:$PATH
     - curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.7/2022-10-31/bin/linux/amd64/kubectl
     - chmod +x kubectl
     - mv ./kubectl /usr/local/bin/kubectl
     - echo Update kubeconfig…
     - aws eks update-kubeconfig --name ${EKS_NAME} --region ${REGION}

  install:
    commands:
      - "apt install unzip -y"
      - "wget https://releases.hashicorp.com/terraform/1.4.0-alpha20221207/terraform_1.4.0-alpha20221207_linux_amd64.zip"
      - "unzip terraform_1.4.0-alpha20221207_linux_amd64.zip"
      - "mv terraform /usr/local/bin/"
      - cd 46-EKS-EFS-CSI-Install/02-efs-install-terraform-manifests/
      - cat c1-versions.tf
      - terraform version
   #   - terraform init
     # - terraform refresh
    #  - terraform plan
      
  build:
    commands:
     # - terraform apply -auto-approve

  post_build:
    commands:
      - echo terraform completed on `date`


[Container] 2023/01/01 15:53:47 Running command kubectl get pod
error: You must be logged in to the server (Unauthorized)

[Container] 2023/01/01 16:20:51 Running command aws sts get-caller-identity
{
    "UserId": "AROA6AGHJZMLPLR4G56SF:AWSCodeBuild-d3704608-2a1e-47e9-8d40-5b33ba2ece06",
    "Account": "962490649366",
    "Arn": "arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-d3704608-2a1e-47e9-8d40-5b33ba2ece06"
}
https://medium.com/adfolks/how-to-give-permission-to-aws-code-build-to-access-eks-cluster-using-a-role-25ca7be73993


aws-auth 
arn:aws:iam::962490649366:role/containerAppBuildProjectRole
arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-f196ef9e-09be-415d-823d-d3e6c3bdbe67
Build ARN
arn:aws:codebuild:us-east-2:962490649366:build/efs-1:ddc6cfd2-80b2-4ce9-9888-596351ebe02e
EKS full access 
aws-auth role access

- aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --role-arn arn:aws:iam::44755xxxxxxx:role/EksCodeBuildkubectlRole

An error occurred (AccessDenied) when calling the AssumeRole operation:
 User: arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-ddc6cfd2-80b2-4ce9-9888-596351ebe02e is not authorized to perform: sts:AssumeRole on resource: arn:aws:sts::962490649366:assumed-role/containerAppBuildProjectRole/AWSCodeBuild-f196ef9e-09be-415d-823d-d3e6c3bdbe67


 Error: creating EFS file system: AccessDeniedException: 

how to avoid these error if delete terraform.tfstate
│ Error: failed creating IAM Role (containerAppBuildProjectRole): EntityAlreadyExists: Role with name containerAppBuildProjectRole already exists.   
│       status code: 409, request id: a14a2103-8615-4615-a18d-52f5a7a0954c
│
│   with aws_iam_role.containerAppBuildProjectRole,
│   on 1.pipeline.tf line 25, in resource "aws_iam_role" "containerAppBuildProjectRole":
│   25: resource "aws_iam_role" "containerAppBuildProjectRole" {
│
╵
╷
│ Error: failed creating IAM Role (apps-code-pipeline-role): EntityAlreadyExists: Role with name apps-code-pipeline-role already exists.
│       status code: 409, request id: 6667b6f1-c742-4b6d-b75a-d0403c079a52
│
│   with aws_iam_role.apps_codepipeline_role,
│   on 1.pipeline.tf line 513, in resource "aws_iam_role" "apps_codepipeline_role":
│  513: resource "aws_iam_role" "apps_codepipeline_role" {
│


















*/
