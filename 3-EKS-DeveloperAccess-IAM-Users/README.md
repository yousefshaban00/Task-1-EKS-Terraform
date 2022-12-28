

###  Test EKS-DeveloperAccess-IAM-Users
---
#### Enabling IAM users/roles Access on Amazon EKS cluster


* Add IAM users or roles to your Amazon EKS cluster

When you create an Amazon EKS cluster, the AWS Identity and Access Management (IAM) entity user or role, such as a federated user that creates the cluster, is automatically granted system:masters permissions in the cluster's role-based access control (RBAC) configuration in the Amazon EKS control plane. This IAM entity doesn't appear in any visible configuration, so make sure to keep track of which IAM entity originally created the cluster. To grant additional AWS users or roles the ability to interact with your cluster, you must edit the aws-auth ConfigMap within Kubernetes and create a Kubernetes rolebinding or clusterrolebinding with the name of a group that you specify in the aws-auth ConfigMap.









