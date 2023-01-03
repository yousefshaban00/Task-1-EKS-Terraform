## AWS CodePipeline+CodeBuild using Terraform to make automation process for Python Task

**we use AWS CodePipeline to make automatically test,build and deploy python app (Cluster health check) as the follwoing steps:**

![Alt text](Task-1-EKS-Terraform/7-EKS-Pipeline/screencapture-us-east-2-console-aws-amazon-codesuite-codepipeline-pipelines-EKS-pipeline-view-2023-01-03-19_03_42.png)



#### Step 00: We define Terraform Settings and provider `c1-version.tf`

```
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
    key    = "dev/py-pipelinee/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "py-pipeline"    
  }    



}

provider "aws" {
  region = var.aws_region
}

```

#### Step 01: We define Github Source as Connection for Pipeline `c2-source.tf`


```

resource "aws_codestarconnections_connection" "github" {
  name = "github-connection"
  provider_type = "GitHub"
  #provider_version = "2"
  #host_arn = "arn:aws:codestar-connections:us-east-1:962490649366:connection/efs-1"
 # host_arn = aws_codestar_connections_host.github.arn
  #access_token_arn = "arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:GITHUB_SECRET_NAME"
 # access_token_arn = "arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:GITHUB_SECRET_NAME"

}



```


#### Step 02: We define IAM roles and Polices for AWS CodePipeline and CodeBuild `c3-iam-role-policy.tf`


```
resource "aws_iam_role" "containerAppBuildProjectRole" {
  name = "containerAppBuildProjectRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# add managed Polcy
# IAM full access

resource "aws_iam_policy_attachment" "IAMFullAccess" {
  name       = "IAMFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
  roles      = [aws_iam_role.containerAppBuildProjectRole.name]
}

# S3 Full access
resource "aws_iam_policy_attachment" "AmazonS3FullAccess" {
  name       = "AmazonS3FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.containerAppBuildProjectRole.name]
}

# DynamoDB full access
resource "aws_iam_policy_attachment" "AmazonDynamoDBFullAccess" {
  name       = "AmazonDynamoDBFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  roles      = [aws_iam_role.containerAppBuildProjectRole.name]
}


resource "aws_iam_role" "apps_codepipeline_role" {
  name = "apps-code-pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

```

*  **buildspec  = "${file("buildspec_python.yml")}"**

```
version: 0.2

#env:
  #variables:
     # key: "There are no variables"
  #parameter-store:
     # key: "There are no variables"

phases:
  install:
    #If you use the Ubuntu standard image 2.0 or later, you must specify runtime-versions.
    #If you specify runtime-versions and use an image other than Ubuntu standard image 2.0, the build fails.
    runtime-versions:
       python: 3.10

  pre_build:
    commands:
     - apt-get update
     - pip install -r python_app_Pipeline/Dockerfile_py_Pipeline/requirements.txt
     - curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     - unzip awscliv2.zip
     - sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
   #  - REGION=us-east-1
     - REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')

     - AWS_ACCOUNTID=962490649366
     #- COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1–7)
    # - IMAGE_TAG=${COMMIT_HASH:=latest}
   #  - EKS_NAME= $(aws eks list-clusters --query 'clusters[0]' --output text)
     - EKS_NAME=radio-dev-ekstask1
     -  curl -o aws-iam-authenticator https://amazon-eks.s3.us-east-1.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
     - chmod +x ./aws-iam-authenticator
     - mkdir -p ~/bin && cp ./aws-iam-authenticator ~/bin/aws-iam-authenticator && export PATH=~/bin:$PATH
     - curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.7/2022-10-31/bin/linux/amd64/kubectl
     - chmod +x kubectl
     - mv ./kubectl /usr/local/bin/kubectl
     - echo Update kubeconfig…
     - aws eks update-kubeconfig --name ${EKS_NAME} --region ${REGION}
     - kubectl version --short --client
   #  - cat ~/.aws/config
  #  - cat ~/.aws/credentials
  #   - cat ~/.kube/config
     - aws sts get-caller-identity
   #  - mkdir -p ~/.aws/
   #  - echo "[profile codebuild]" >> ~/.aws/config
  #   - echo "role_arn = arn:aws:iam::$AWS_ACCOUNT_ID:role/containerAppBuildProjectRole" >> ~/.aws/config
   #  - echo "region = us-east-1"
   #  - echo "output = json"
   #  - cat ~/.aws/config
  #  -  aws eks update-kubeconfig --name ${EKS_NAME} --region ${REGION} --role-arn arn:aws:iam::962490649366:role/containerAppBuildProjectRole
    # -  aws eks update-kubeconfig --name ${EKS_NAME} --region ${REGION} 
     - kubectl get pod
     - kubectl get svc
     - echo $IMAGE_REPO_NAME
     - echo $IMAGE_TAG
     #- echo $PASS
     # define PASS as AWS SSM Parameter Store 
     - password=$(aws ssm get-parameters --region us-east-1 --names PASS --with-decryption --query Parameters[0].Value)
     - password=`echo $password | sed -e 's/^"//' -e 's/"$//'`
     - python python_app_Pipeline/test.py

     #- $IMAGE_REPO_NAME=yousefshaban/my-python-app
    # - $IMAGE_TAG=latest

  build:
    commands:
      - docker login --username yousefshaban --password ${password}
      - echo Build started on `date`
      - echo Building the Docker image...          
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG python_app_Pipeline/Dockerfile_py_Pipeline
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $IMAGE_REPO_NAME:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $IMAGE_REPO_NAME:$IMAGE_TAG


```





#### Step 03: We define AWS CodeBuild Projects for Pipeline `c4-build.tf`


```
# aws codebuild - First - python and auth with K8s  ************************************

resource "aws_codebuild_project" "containerAppBuild" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "python_app"



  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    # name                   = "container-app-code-${var.env}"
    # override_artifact_name = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }



  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    environment_variable {
              name  = "IMAGE_REPO_NAME"
              type  = "PLAINTEXT"
              value = "yousefshaban/my-python-app"
    }

    environment_variable {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
    }



  }


  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

# how we can dd more source for aws_codebuild_project

  source {

    buildspec  = "${file("buildspec_python.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
  #  type                = "CODEPIPELINE"
    type                = "CODEPIPELINE"
  }
}



```



#### Step 04: We define AWS CodePipeline for all Stages of Source and Builds `c5-pipeline.tf`


```
resource "aws_s3_bucket" "cicd_bucket" {
  bucket = "my-artifact-store-i"
#  acl    = "private"
}

resource "aws_codepipeline" "node_app_pipeline" {
  name     = "python-app-pipeline"
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  tags = {
    Environment = var.env
  }
  artifact_store {
    location = aws_s3_bucket.cicd_bucket.bucket
    type     = "S3"
  }


  stage {
    name = "Source"

    action {
      category = "Source"
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      #owner     = "ThirdParty"
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"     
      #provider  = "GitHub"
      run_order = 1
      version   = "1"   # ??? 1 or 2 
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.python_project_repository_name
        BranchName       = var.python_project_repository_branch
      }



    }
  }





  stage {
  
    name = "Build-python"

    action {
       name = "Build-python"
      category = "Build"
         run_order = 2
      # region ??
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
            {
              name  = "AWS_DEFAULT_REGION"
              type  = "PLAINTEXT"
              value = var.aws_region
            },
            #   {
            #   name  = "PASS" >>> you can add on parameter store and use it on Buildspec.yml
            #   - password=$(aws ssm get-parameters --region us-east-1 --names PASS --with-decryption --query Parameters[0].Value)
            # - password=`echo $password | sed -e 's/^"//' -e 's/"$//'`
            #   type  = "PARAMETER_STORE"
            #   value = "ACCOUNT_ID"
  
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
     
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
   #   run_order = 1
      version   = "1"
    }
  }



```



#### Step 05: We define Outputs `c6-outputs.tf`


```
output "code_build_project" {
  value = aws_codebuild_project.containerAppBuild.arn
}
output "python_codepipeline_project" {
  value = aws_codepipeline.python_pipeline.arn
}



```



#### Step 06: We define Variables `c7-variables.tf`


```

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
variable "env" {
  description = "Targeted Depolyment environment"
  default     = "dev"
}
variable "python_project_repository_name" {
  description = "Nodejs Project Repository name to connect to"
  default     = "yousefshaban00/pipeline01"
}
variable "python_project_repository_branch" {
  description = "Nodejs Project Repository branch to connect to"
  default     = "main"
}


variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "python-app"
}


```



#### Outputs and Verify 



![Alt text](python_app_Pipeline/Capture2.PNG)
```

[Container] 2023/01/02 17:24:53 Running command echo $IMAGE_REPO_NAME
yousefshaban/my-python-app

[Container] 2023/01/02 17:24:53 Running command echo $IMAGE_TAG
latest

[Container] 2023/01/02 17:24:53 Running command password=$(aws ssm get-parameters --region us-east-1 --names PASS --with-decryption --query Parameters[0].Value)

[Container] 2023/01/02 17:24:53 Running command password=`echo $password | sed -e 's/^"//' -e 's/"$//'`

[Container] 2023/01/02 17:24:53 Running command python python_app_Pipeline/test.py
