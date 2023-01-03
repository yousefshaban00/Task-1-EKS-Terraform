# aws codebuild - First - python and auth with K8s  ************************************

resource "aws_codebuild_project" "EKSBuild" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "EKS-Cluster"



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
    # environment_variable {
    #           name  = "IMAGE_REPO_NAME"
    #           type  = "PLAINTEXT"
    #           value = "yousefshaban/my-python-app"
    # }

    # environment_variable {
    #           name  = "IMAGE_TAG"
    #           type  = "PLAINTEXT"
    #           value = "latest"
    # }



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

    buildspec  = "${file("buildspec_eks-1.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
  #  type                = "CODEPIPELINE"
    type                = "CODEPIPELINE"
  }
}


#aws codeBuild - Project 2-1 - Install EBS  *********************************************
resource "aws_codebuild_project" "containerAppBuild_ebs" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "eks-ebs"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-ebs-2.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

#aws codeBuild - Project 2-2 - deploy app to check EBS  *********************************************
resource "aws_codebuild_project" "containerAppBuild_ebs_app" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "ebs_app"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-ebs-2-2.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}


#aws codeBuild - Project 3 - 3-EKS-DeveloperAccess-IAM-Users 3-k8sresources-terraform-manifests  *********************************************

resource "aws_codebuild_project" "containerAppBuild_iam" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "eks-iam"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-iam-3.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}



#aws codeBuild - project 4 -  4-EKS-Cluster-Autoscaler  4.1 install CAS  *********


resource "aws_codebuild_project" "containerAppBuild_cas" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "cas"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-cas-4.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}


#aws codeBuild - project 4 -  4-EKS-Cluster-Autoscaler  4.2 deploy app  *********


# resource "aws_codebuild_project" "containerAppBuild_cas_app" {
#   badge_enabled  = false
#   build_timeout  = 60
#   name           = "cas_app"

#   queued_timeout = 480
#   service_role   = aws_iam_role.containerAppBuildProjectRole.arn
#   tags = {
#     Environment = var.env
#   }

#   artifacts {
#     encryption_disabled = false
#     packaging = "NONE"
#     type      = "CODEPIPELINE"
#   }
# environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:6.0"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true
#     type                        = "LINUX_CONTAINER"
#   }

#   logs_config {
#     cloudwatch_logs {
#       status = "ENABLED"
#     }

#     s3_logs {
#       encryption_disabled = false
#       status              = "DISABLED"
#     }
#   }

#   source {
#     # buildspec           = data.template_file.buildspec.rendered
#     buildspec  = "${file("buildspec_eks-cas-4-2.yml")}"
#     git_clone_depth     = 0
#     insecure_ssl        = false
#     report_build_status = false
#     type                = "CODEPIPELINE"
#   }
# }

#aws codeBuild - project 5  **************************************************************

#aws codeBuild - project 5 -  5.1 1-k8s-metrics-server-terraform-manifests *********

resource "aws_codebuild_project" "containerAppBuild_metrics" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "metrics"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-hpa-5.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}


#aws codeBuild - project 5 -  5.2 2-hpa-demo-yaml *********

# containerAppBuild_efs_dynamic Project 4
# resource "aws_codebuild_project" "containerAppBuild_hpa_demo" {
#   badge_enabled  = false
#   build_timeout  = 60
#   name           = "hpa_demo"

#   queued_timeout = 480
#   service_role   = aws_iam_role.containerAppBuildProjectRole.arn
#   tags = {
#     Environment = var.env
#   }

#   artifacts {
#     encryption_disabled = false
#     packaging = "NONE"
#     type      = "CODEPIPELINE"
#   }
# environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:6.0"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true
#     type                        = "LINUX_CONTAINER"
#   }

#   logs_config {
#     cloudwatch_logs {
#       status = "ENABLED"
#     }

#     s3_logs {
#       encryption_disabled = false
#       status              = "DISABLED"
#     }
#   }

#   source {
#     # buildspec           = data.template_file.buildspec.rendered
#     buildspec  = "${file("buildspec_eks-hpa-5-2.yml")}"
#     git_clone_depth     = 0
#     insecure_ssl        = false
#     report_build_status = false
#     type                = "CODEPIPELINE"
#   }
# }



#aws codeBuild - project 5 -  5.3 3-hpa-demo-terraform-manifests *********

resource "aws_codebuild_project" "containerAppBuild_hpa_app" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "hpa_app"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-hpa-5-3.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}


#aws codeBuild - project 6 -  6-Monitoring-Logging-Terraform *********

resource "aws_codebuild_project" "containerAppBuild_Monitoring" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "Monitoring"

  queued_timeout = 480
  service_role   = aws_iam_role.containerAppBuildProjectRole.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled = false
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
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

  source {
    # buildspec           = data.template_file.buildspec.rendered
    buildspec  = "${file("buildspec_eks-monitor-6.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
