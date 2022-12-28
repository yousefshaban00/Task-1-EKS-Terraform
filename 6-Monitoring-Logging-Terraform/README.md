###  Setup a Kubernetes cluster on AWS EKS infrastructure

## EKS Monitoring and logging

all info about architect Design:

![Alt text](./Capture.PNG)

There are several ways to monitor and log the resources and applications running on an Amazon Elastic Container Service for Kubernetes (EKS) cluster. Here are some common options:

* Amazon CloudWatch: Amazon CloudWatch is a monitoring and logging service provided by AWS that allows you to monitor the resources and applications running on your EKS cluster. You can use CloudWatch to collect and view logs, metrics, and events from your EKS cluster, as well as set up alarms and notifications based on specific thresholds or patterns.

* Kubernetes Dashboard: The Kubernetes Dashboard is a web-based UI that provides a view into the state of your EKS cluster, including the status of your pods, services, and deployments. You can use the Kubernetes Dashboard to view logs, monitor resource utilization, and troubleshoot issues in your cluster.

* Prometheus and Grafana: Prometheus is a popular open-source monitoring and alerting system, and Grafana is a visualization tool for monitoring and analytics. You can use Prometheus and Grafana to monitor the resources and applications running on your EKS cluster by collecting metrics from your cluster and visualizing them in Grafana.

* AWS X-Ray: AWS X-Ray is a distributed tracing system that allows you to trace the request and response paths of your applications and identify performance issues and errors. You can use X-Ray to monitor the applications running on your EKS cluster and analyze the performance of your applications.

* The Amazon CloudWatch Agent is a software program that you can install on your Amazon Elastic Compute Cloud (EC2) instances, on-premises servers, and virtual machines (VMs) to collect log data and system-level metrics from your resources and send them to CloudWatch. The CloudWatch Agent allows you to monitor the performance and availability of your resources in real-time, set alarms based on specific thresholds or patterns, and troubleshoot issues with your resources.

* Fluent Bit is an open-source data collector that allows you to collect, parse, and forward logs and other data from various sources to different destinations. Fluent Bit is designed to be lightweight and efficient, making it well-suited for use in containerized environments, such as Kubernetes clusters. To use Fluent Bit in a Kubernetes cluster, you can install Fluent Bit as a DaemonSet, which will ensure that a Fluent Bit pod is running on each worker node in the cluster. You can then configure Fluent Bit to collect logs and other data from the worker nodes and forward them to a destination such as Amazon CloudWatch or Elasticsearch.

 * **Kubectl Provder**
 
The kubectl provider is a Terraform plugin that allows you to use Terraform to manage resources in a Kubernetes cluster using the kubectl command-line tool. The kubectl provider can be used to create, update, and delete resources such as pods, services, and deployments in a Kubernetes cluster.

To use the kubectl provider in your Terraform configuration, you will need to specify the provider block in your configuration file and specify the kubectl provider. You will also need to configure the provider with the necessary credentials and connection information for your Kubernetes cluster.







**Create  Terraform Configuration:** `c1-versions.tf`
```
# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
     }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }    
    http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }     
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }     
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "aws-eks-terraform"
    key    = "dev/eks-cloudwatch-agent/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-eks-cloudwatch-agent"    
  }     
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


**Create terraform-providers.tf Configuration:** `c4-01-terraform-providers.tf.tf`
```
# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}

provider "http" {
  # Configuration options
}

# Datasource: EKS Cluster Authentication
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Terraform kubectl Provider
provider "kubectl" {
  # Configuration options
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


```

**Create cwagent-namespace Terraform Configuration:** `c4-02-cwagent-namespace.tf`
```
## Resource: Namespace
resource "kubernetes_namespace_v1" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }
}
```



**Create cwagent-service-accounts-cr-crbTerraform Configuration:** `c4-03-cwagent-service-accounts-cr-crb.tf`
```
# Resource: Service Account, ClusteRole, ClusterRoleBinding

# Datasource
data "http" "get_cwagent_serviceaccount" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml"
  # Optional request headers
  request_headers = {
    Accept = "text/*"
  }
}

# Datasource: kubectl_file_documents 
# This provider provides a data resource kubectl_file_documents to enable ease of splitting multi-document yaml content.
data "kubectl_file_documents" "cwagent_docs" {
    content = data.http.get_cwagent_serviceaccount.response_body
}

# Resource: kubectl_manifest which will create k8s Resources from the URL specified in above datasource
resource "kubectl_manifest" "cwagent_serviceaccount" {
    depends_on = [kubernetes_namespace_v1.amazon_cloudwatch]
    for_each = data.kubectl_file_documents.cwagent_docs.manifests
    yaml_body = each.value
}
```


**Create cwagent-configmap Terraform Configuration:** `c4-04-cwagent-configmap.tf`
```
# Resource: CloudWatch Agent ConfigMap
resource "kubernetes_config_map_v1" "cwagentconfig_configmap" {
  metadata {
    name = "cwagentconfig" 
    namespace = kubernetes_namespace_v1.amazon_cloudwatch.metadata[0].name 
  }
  data = {
    "cwagentconfig.json" = jsonencode({
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "metrics_collection_interval": 60
          }
        },
        "force_flush_interval": 5
      }
    })
  }
}
```



**Create cwagent-daemonset Terraform Configuration:** `c4-05-cwagent-daemonset.tf`
```
# Resource: Daemonset

# Datasource
data "http" "get_cwagent_daemonset" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml"
  # Optional request headers
  request_headers = {
    Accept = "text/*"
  }
}

# Resource: kubectl_manifest which will create k8s Resources from the URL specified in above datasource
resource "kubectl_manifest" "cwagent_daemonset" {
    depends_on = [
      kubernetes_namespace_v1.amazon_cloudwatch,
      kubernetes_config_map_v1.cwagentconfig_configmap,
      kubectl_manifest.cwagent_serviceaccount
      ]
    yaml_body = data.http.get_cwagent_daemonset.response_body
}
```

**Create fluentbit-configmap Terraform Configuration:** `c5-01-fluentbit-configmap.tf`
```
# Resource: FluentBit Agent ConfigMap
resource "kubernetes_config_map_v1" "fluentbit_configmap" {
  metadata {
    name = "fluent-bit-cluster-info"
    namespace = kubernetes_namespace_v1.amazon_cloudwatch.metadata[0].name 
  }
  data = {
    "cluster.name" = data.terraform_remote_state.eks.outputs.cluster_id
    "http.port"   = "2020"
    "http.server" = "On"
    "logs.region" = var.aws_region
    "read.head" = "Off"
    "read.tail" = "On"
  }
}
```



**Create fluentbit-daemonset Terraform Configuration:** `c5-02-fluentbit-daemonset.tf`
```
# Resources: FluentBit 
## - ServiceAccount
## - ClusterRole
## - ClusterRoleBinding
## - ConfigMap: fluent-bit-config
## - DaemonSet

# Datasource
data "http" "get_fluentbit_resources" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml"
  # Optional request headers
  request_headers = {
    Accept = "text/*"
  }
}

# Datasource: kubectl_file_documents 
# This provider provides a data resource kubectl_file_documents to enable ease of splitting multi-document yaml content.
data "kubectl_file_documents" "fluentbit_docs" {
    content = data.http.get_fluentbit_resources.response_body
}

# Resource: kubectl_manifest which will create k8s Resources from the URL specified in above datasource
resource "kubectl_manifest" "fluentbit_resources" {
  depends_on = [
    kubernetes_namespace_v1.amazon_cloudwatch,
    kubernetes_config_map_v1.fluentbit_configmap,
    kubectl_manifest.cwagent_daemonset
    ]
  for_each = data.kubectl_file_documents.fluentbit_docs.manifests    
  yaml_body = each.value
}
```
















