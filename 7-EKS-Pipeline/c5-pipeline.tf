


resource "aws_s3_bucket" "cicd_bucket" {
  bucket = "my-artifact-store-i"
#  acl    = "private"
}

resource "aws_codepipeline" "eks_pipeline" {
  name     = "EKS-pipeline"
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
        FullRepositoryId = var.eks_repository_name
        BranchName       = var.eks_repository_branch
      }



    }
  }





  stage {
  
    name = "Build-EKS"

    action {
       name = "Build-EKS"
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
            #   - password=$(aws ssm get-parameters --region us-east-2 --names PASS --with-decryption --query Parameters[0].Value)
            # - password=`echo $password | sed -e 's/^"//' -e 's/"$//'`
            #   type  = "PARAMETER_STORE"
            #   value = "ACCOUNT_ID"
  
 
          ]
        )
        "ProjectName" = aws_codebuild_project.EKSBuild.name
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




# EBS 

stage {

   name = "Build-EBS"

    action {
       name = "EBS-addon"
      category = "Build"
      run_order = 3
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_ebs.name
      }

      input_artifacts = [
        "SourceArtifact",
      ]
     
      output_artifacts = [
        "BuildArtifact-4",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }

    action {
      name = "EBS-APP"
      category = "Build"
      run_order = 4
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_ebs_app.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
  
      output_artifacts = [
        "BuildArtifact-5",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }



  }



stage {

   name = "Build-IAM"

    action {
       name = "IAM-USER"
      category = "Build"
      run_order = 3
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_iam.name
      }

      input_artifacts = [
        "SourceArtifact",
      ]
     
      output_artifacts = [
        "BuildArtifact-6",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }

}




stage {

   name = "Build-CAS"

    action {
       name = "CAS-Deploy"
      category = "Build"
      run_order = 3
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_cas.name
      }

      input_artifacts = [
        "SourceArtifact",
      ]
     
      output_artifacts = [
        "BuildArtifact-7",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }


  }



#HPA
stage {

   name = "Build-Metric"

    action {
       name = "Metrics"
      category = "Build"
      run_order = 3
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_metrics.name
      }

      input_artifacts = [
        "SourceArtifact",
      ]
     
      output_artifacts = [
        "BuildArtifact-8",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }

    action {
      name = "Build-HPA"
      category = "Build"
      run_order = 4
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_hpa_app.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
  
      output_artifacts = [
        "BuildArtifact-9",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }



  }


# Montioring and Logging
stage {

   name = "Build-Monitor"

    action {
       name = "Monitor-Deploy"
      category = "Build"
      run_order = 3
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
            }
 
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild_Monitoring.name
      }

      input_artifacts = [
        "SourceArtifact",
      ]
     
      output_artifacts = [
        "BuildArtifact-10",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
  
      version   = "1"
    }


  }







}












#Start the pipeline on source code change
#  triggers {
#     webhook {
#       name = "WebhookTrigger"
#     }





#create separate stages for each repository using terraform
/*
To create separate pipeline stages for each Git repository source using Terraform, you can use the aws_codepipeline_stage resource.

Here is an example of how you can set this up:

resource "aws_codepipeline_stage" "repo1_stage" {
  name       = "Repo1"
  action {
    name            = "Repo1Action"
    category        = "Source"
    owner           = "ThirdParty"
    provider        = "GitHub"
    version         = "1"
    output_artifacts = ["Repo1Artifact"]
    configuration {
      Owner  = "your-github-username"
      Repo   = "repo1"
      Branch = "master"
    }
  }
  pipeline_name = aws_codepipeline.pipeline.name
}

resource "aws_codepipeline_stage" "repo2_stage" {
  name       = "Repo2"
  action {
    name            = "Repo2Action"
    category        = "Source"
    owner           = "ThirdParty"
    provider        = "GitHub"
    version         = "1"
    output_artifacts = ["Repo2Artifact"]
    configuration {
      Owner  = "your-github-username"
      Repo   = "repo2"
      Branch = "master"
    }
  }
  pipeline_name = aws_codepipeline.pipeline.name
}

You can then use the output_artifacts of each stage as the input_artifacts for the next stage in the pipeline.





*/





# resource "aws_codestar_connections_host" "github" {
#   provider = "GITHUB"
#   name = "github-connection-host"
#   owner_aws_account_id = "962490649366"
# }


# data "aws_iam_policy_document" "codepipeline" {
#   statement {
#     actions = ["s3:*"]
#     resources = [
#       aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*",
#       aws_s3_bucket.repos.arn, "${aws_s3_bucket.repos.arn}/*",
#     ]
#     effect = "Allow"
#   }
#   statement {
#     actions   = ["codestar-connections:UseConnection"]
#     resources = [aws_codestarconnections_connection.github.arn]
#     effect    = "Allow"
#   }
# }





# resource "aws_s3_bucket" "artifact_store" {
#   bucket = "my-artifact-store"
#   acl    = "private"
# }

# First Pipeline 
# resource "aws_codepipeline" "node_app_pipeline" {
#   name     = "python-app-pipeline"
#   role_arn = aws_iam_role.apps_codepipeline_role.arn
#   tags = {
#     Environment = var.env
#   }
#   artifact_store {
#     location = aws_s3_bucket.cicd_bucket.bucket
#     type     = "S3"
#   }


# #   artifact_store {
# #     location = var.artifacts_bucket_name
# #     type     = "S3"
# #   }




#   stage {
#     name = "Source"

#     action {
#       category = "Source"
#       input_artifacts = []
#       name            = "Source"
#       output_artifacts = [
#         "SourceArtifact",
#       ]
#       #owner     = "ThirdParty"
#       owner     = "AWS"
#       provider  = "CodeStarSourceConnection"     
#       #provider  = "GitHub"
#       run_order = 1
#       version   = "1"   # ??? 1 or 2 
#     #   configuration = {
#     #     # "BranchName"           = var.nodejs_project_repository_branch
#     #     # # "PollForSourceChanges" = "false"
#     #     # "RepositoryName"       = var.nodejs_project_repository_name
#     #     Owner  = "yousefshaban00"
#     #     Repo   = "Get_Course"
#     #     Branch = "master"
#     #   #  OAuthToken = "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"
#     #   }
#       configuration = {
#         ConnectionArn    = aws_codestarconnections_connection.github.arn
#         FullRepositoryId = var.nodejs_project_repository_name
#         BranchName       = var.nodejs_project_repository_branch
#       }






# # connection ???



#     }
#   }

# #Start the pipeline on source code change
# #  triggers {
# #     webhook {
# #       name = "WebhookTrigger"
# #     }





#   stage {
  
#     name = "Build-python"

#     action {
#        name = "Build-python"
#       category = "Build"
#          run_order = 2
#       # region ??
#       configuration = {
#         "EnvironmentVariables" = jsonencode(
#           [
#             {
#               name  = "environment"
#               type  = "PLAINTEXT"
#               value = var.env
#             },
#             {
#               name  = "AWS_DEFAULT_REGION"
#               type  = "PLAINTEXT"
#               value = var.aws_region
#             },
#             #   {
#             #   name  = "PASS"
#             #   type  = "PARAMETER_STORE"
#             #   value = "ACCOUNT_ID"
#             # },
#             #,
#             # {
#             #   name  = "AWS_ACCOUNT_ID"
#             #   type  = "PARAMETER_STORE"
#             #   value = "ACCOUNT_ID"
#             # },
#             # {
#             #   name  = "IMAGE_REPO_NAME"
#             #   type  = "PLAINTEXT"
#             #   value = "yousefshaban/my-python-app"
#             # },
#             # {
#             #   name  = "IMAGE_TAG"
#             #   type  = "PLAINTEXT"
#             #   value = "latest"
#             # }
#             #,
#             # {
#             #   name  = "CONTAINER_NAME"
#             #   type  = "PLAINTEXT"
#             #   value = "nodeAppContainer"
#             # },
#           ]
#         )
#         "ProjectName" = aws_codebuild_project.containerAppBuild.name
#       }
#       input_artifacts = [
#         "SourceArtifact",
#       ]
     
#       output_artifacts = [
#         "BuildArtifact",
#       ]
#       owner     = "AWS"
#       provider  = "CodeBuild"
#    #   run_order = 1
#       version   = "1"
#     }
#   }


# ************* 
# stage {
  
#     name = "EFS-Project"

#     action {
#       name = "EFS-Install"
#       category = "Build"
#         run_order = 3
#       # region ??
#       configuration = {
#         "EnvironmentVariables" = jsonencode(
#           [
#             {
#               name  = "environment"
#               type  = "PLAINTEXT"
#               value = var.env
#             },
#             {
#               name  = "AWS_DEFAULT_REGION"
#               type  = "PLAINTEXT"
#               value = var.aws_region
#             }
 
#           ]
#         )
#         "ProjectName" = aws_codebuild_project.containerAppBuild_efs.name
#       }

#       input_artifacts = [
#         "SourceArtifact",
#       ]

#       output_artifacts = [
#         "BuildArtifact-2",
#       ]
#       owner     = "AWS"
#       provider  = "CodeBuild"
     
#       version   = "1"
#     }


 # }

#disable tranisition aws codepipeline using terraform

#disable tranisition aws codepipeline using terraform






# add action
# add action group








# stage {
#     name = "Build2"

#     action {
#       name            = "Build2"
#       category        = "Build"
#       owner           = "AWS"
#       provider        = "${aws_codebuild_project.project2.name}"
#       version         = "1"
#       input_artifacts = ["example-output-build1"]
#       output_artifacts = ["example-output-build2"]
#     }
# }









#   stage {
#     name = "Deploy"

#     action {
#       category = "Deploy"
#       configuration = {
#         "ClusterName" = var.aws_ecs_cluster_name
#         "ServiceName" = var.aws_ecs_node_app_service_name
#         "FileName"    = "imagedefinitions.json"
#         #"DeploymentTimeout" = "15"
#       }
#       input_artifacts = [
#         "BuildArtifact",
#       ]
#       name             = "Deploy"
#       output_artifacts = []
#       owner            = "AWS"
#       provider         = "ECS"
#       run_order        = 1
#       version          = "1"
#     }
   #}
#}


# second AWs pipeline

# resource "aws_codepipeline" "python_app_pipeline" {
#   name     = "python-app-pipeline"
#   role_arn = aws_iam_role.apps_codepipeline_role.arn
#   tags = {
#     Environment = var.env
#   }

#   artifact_store {
#     location = var.artifacts_bucket_name
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       category = "Source"
#       configuration = {
#         "BranchName"           = var.python_project_repository_branch
#         # "PollForSourceChanges" = "false"
#         "RepositoryName"       = var.python_project_repository_name
#       }
#       input_artifacts = []
#       name            = "Source"
#       output_artifacts = [
#         "SourceArtifact",
#       ]
#       owner     = "AWS"
#       provider  = "CodeCommit"
#       run_order = 1
#       version   = "1"
#     }
#   }
#   stage {
#     name = "Build"

#     action {
#       category = "Build"
#       configuration = {
#         "EnvironmentVariables" = jsonencode(
#           [
#             {
#               name  = "environment"
#               type  = "PLAINTEXT"
#               value = var.env
#             },
#             {
#               name  = "AWS_DEFAULT_REGION"
#               type  = "PLAINTEXT"
#               value = var.aws_region
#             },
#             {
#               name  = "AWS_ACCOUNT_ID"
#               type  = "PARAMETER_STORE"
#               value = "ACCOUNT_ID"
#             },
#             {
#               name  = "IMAGE_REPO_NAME"
#               type  = "PLAINTEXT"
#               value = "nodeapp"
#             },
#             {
#               name  = "IMAGE_TAG"
#               type  = "PLAINTEXT"
#               value = "latest"
#             },
#             {
#               name  = "CONTAINER_NAME"
#               type  = "PLAINTEXT"
#               value = "pythonAppContainer"
#             },
#           ]
#         )
#         "ProjectName" = aws_codebuild_project.containerAppBuild.name
#       }
#       input_artifacts = [
#         "SourceArtifact",
#       ]
#       name = "Build"
#       output_artifacts = [
#         "BuildArtifact",
#       ]
#       owner     = "AWS"
#       provider  = "CodeBuild"
#       run_order = 1
#       version   = "1"
#     }
#   }
#   stage {
#     name = "Deploy"

#     action {
#       category = "Deploy"
#       configuration = {
#         "ClusterName" = var.aws_ecs_cluster_name
#         "ServiceName" = var.aws_ecs_python_app_service_name
#         "FileName"    = "imagedefinitions.json"
#         #"DeploymentTimeout" = "15"
#       }
#       input_artifacts = [
#         "BuildArtifact",
#       ]
#       name             = "Deploy"
#       output_artifacts = []
#       owner            = "AWS"
#       provider         = "ECS"
#       run_order        = 1
#       version          = "1"
#     }
#   }
# }


# resource "aws_codepipeline" "go_app_pipeline" {
#   name     = "go-app-pipeline"
#   role_arn = aws_iam_role.apps_codepipeline_role.arn
#   tags = {
#     Environment = var.env
#   }

#   artifact_store {
#     location = var.artifacts_bucket_name
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       category = "Source"
#       configuration = {
#         "BranchName"           = var.golang_project_repository_branch
#         # "PollForSourceChanges" = "false"
#         "RepositoryName"       = var.golang_project_repository_name
#       }
#       input_artifacts = []
#       name            = "Source"
#       output_artifacts = [
#         "SourceArtifact",
#       ]
#       owner     = "AWS"
#       provider  = "CodeCommit"
#       run_order = 1
#       version   = "1"
#     }
#   }
#   stage {
#     name = "Build"

#     action {
#       category = "Build"
#       configuration = {
#         "EnvironmentVariables" = jsonencode(
#           [
#             {
#               name  = "environment"
#               type  = "PLAINTEXT"
#               value = var.env
#             },
#             {
#               name  = "AWS_DEFAULT_REGION"
#               type  = "PLAINTEXT"
#               value = var.aws_region
#             },
#             {
#               name  = "AWS_ACCOUNT_ID"
#               type  = "PARAMETER_STORE"
#               value = "ACCOUNT_ID"
#             },
#             {
#               name  = "IMAGE_REPO_NAME"
#               type  = "PLAINTEXT"
#               value = "nodeapp"
#             },
#             {
#               name  = "IMAGE_TAG"
#               type  = "PLAINTEXT"
#               value = "latest"
#             },
#             {
#               name  = "CONTAINER_NAME"
#               type  = "PLAINTEXT"
#               value = "goAppContainer"
#             },
#           ]
#         )
#         "ProjectName" = aws_codebuild_project.containerAppBuild.name
#       }
#       input_artifacts = [
#         "SourceArtifact",
#       ]
#       name = "Build"
#       output_artifacts = [
#         "BuildArtifact",
#       ]
#       owner     = "AWS"
#       provider  = "CodeBuild"
#       run_order = 1
#       version   = "1"
#     }
#   }
#   stage {
#     name = "Deploy"

#     action {
#       category = "Deploy"
#       configuration = {
#         "ClusterName" = var.aws_ecs_cluster_name
#         "ServiceName" = var.aws_ecs_go_app_service_name
#         "FileName"    = "imagedefinitions.json"
#         #"DeploymentTimeout" = "15"
#       }
#       input_artifacts = [
#         "BuildArtifact",
#       ]
#       name             = "Deploy"
#       output_artifacts = []
#       owner            = "AWS"
#       provider         = "ECS"
#       run_order        = 1
#       version          = "1"
#     }
#   }
# }