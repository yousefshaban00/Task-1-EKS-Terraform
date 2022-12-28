

##  Horizontal Pod Autoscaling (HPA) 

all info about architect Design:

![Alt text](./Capture.PNG)

Horizontal Pod Autoscaling (HPA) is a Kubernetes feature that allows you to automatically scale the number of replicas of a Deployment, ReplicaSet, or ReplicationController based on metrics such as CPU usage or memory usage.

To use HPA on an Amazon Elastic Container Service for Kubernetes (EKS) cluster, you will need to install the Kubernetes Metrics Server on your cluster. The Metrics Server is a cluster-wide aggregator of resource usage data that is used by the HPA controller to determine the current resource utilization of your application and decide whether to scale the number of replicas.

* **Helm provider**

In Terraform, the Helm provider is a plugin that allows you to use Terraform to deploy and manage applications on a Kubernetes cluster using the Helm package manager.

To use the Helm provider in your Terraform configuration, you will need to specify the provider block in your configuration file and specify the helm provider. You will also need to configure the provider with the necessary credentials and connection information for your Kubernetes cluster.


* **Kubernetes Metrics Server**
The Kubernetes Metrics Server is a cluster-wide aggregator of resource usage data that is used by the Horizontal Pod Autoscaler (HPA) and the Vertical Pod Autoscaler (VPA) to determine the current resource utilization of your applications and decide whether to scale the number of replicas.

The Metrics Server is implemented as a Deployment and a Service in a Kubernetes cluster, and exposes a RESTful API that is used by the HPA and VPA controllers to retrieve metrics data. The Metrics Server retrieves resource usage data from the Kubernetes API server and the kubelet component on each worker node, and stores the data in memory for fast access.




**Create  Terraform Block Configuration:** `c1-versions.tf`


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
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aws-eks-terraform"
    key    = "dev/eks-metrics-server/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-eks-metrics-server"    
  }     
}

# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
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


**Create helm-provider Terraform Configuration:** `c4-01-helm-provider.tf`

`Data Source: aws_eks_cluster_auth`
Get an authentication token to communicate with an EKS cluster.

Uses IAM credentials from the AWS provider to generate a temporary token that is compatible with AWS IAM Authenticator authentication. This can be used to authenticate to an EKS cluster or to a cluster that has the AWS IAM Authenticator server configured.

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


**Create metrics-server-install Terraform Configuration:** `c4-02-metrics-server-install.tf`
```
# Install Kubernetes Metrics Server using HELM
# Resource: Helm Release 
resource "helm_release" "metrics_server_release" {
  name       = "${local.name}-metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace = "kube-system"   
}



```



**Create metrics-server-outputs Configuration:** `c4-03-metrics-server-outputs.tf`
```
# Helm Release Outputs
output "metrics_server_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.metrics_server_release.metadata
}

```

**Create Horizontal Pod Autoscaler Configuration:** `c6-hpa-resource.tf`
```
# Resource: Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v1" "hpa_myapp3" {
  metadata {
    name = "hpa-app3"
  }
  spec {
    max_replicas = 10
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.myapp3.metadata[0].name 
    }
    target_cpu_utilization_percentage = 50
  }
}

```







