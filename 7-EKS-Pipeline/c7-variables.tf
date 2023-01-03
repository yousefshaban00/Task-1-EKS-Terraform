
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-2"
}
variable "env" {
  description = "Targeted Depolyment environment"
  default     = "dev"
}
variable "eks_repository_name" {
  description = "Nodejs Project Repository name to connect to"
  default     = "yousefshaban00/pipeline01"
}
variable "eks_repository_branch" {
  description = "Nodejs Project Repository branch to connect to"
  default     = "main"
}


variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "python-app"
}


