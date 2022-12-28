

###  Test EKS-DeveloperAccess-IAM-Users
---
#### Enabling IAM users/roles Access on Amazon EKS cluster


* Add IAM users or roles to your Amazon EKS cluster

When you create an Amazon EKS cluster, the AWS Identity and Access Management (IAM) entity user or role, such as a federated user that creates the cluster, is automatically granted system:masters permissions in the cluster's role-based access control (RBAC) configuration in the Amazon EKS control plane. This IAM entity doesn't appear in any visible configuration, so make sure to keep track of which IAM entity originally created the cluster. To grant additional AWS users or roles the ability to interact with your cluster, you must edit the aws-auth ConfigMap within Kubernetes and create a Kubernetes rolebinding or clusterrolebinding with the name of a group that you specify in the aws-auth ConfigMap.


To add an IAM user or role to an Amazon EKS cluster

1. Determine which credentials kubectl is using to access your cluster. On your computer, you can see which credentials kubectl uses with the following command. Replace ~/.kube/config with the path to your kubeconfig file if you don't use the default path.


2. Make sure that you have existing Kubernetes roles and rolebindings or clusterroles and clusterrolebindings that you can map IAM users or roles to. For more information about these resources, see Using RBAC Authorization in the Kubernetes documentation.
View your existing Kubernetes roles or clusterroles. Roles are scoped to a namespace, but clusterroles are scoped to the cluster.


3. Edit the aws-auth ConfigMap. You can use a tool such as eksctl to update the ConfigMap or you can update it manually by editing it.
