

###  Test EKS-DeveloperAccess-IAM-Users
---
#### Enabling IAM users/roles Access on Amazon EKS cluster


* **Add IAM users or roles to your Amazon EKS cluster**

When you create an Amazon EKS cluster, the AWS Identity and Access Management (IAM) entity user or role, such as a federated user that creates the cluster, is automatically granted system:masters permissions in the cluster's role-based access control (RBAC) configuration in the Amazon EKS control plane. This IAM entity doesn't appear in any visible configuration, so make sure to keep track of which IAM entity originally created the cluster. To grant additional AWS users or roles the ability to interact with your cluster, you must edit the aws-auth ConfigMap within Kubernetes and create a Kubernetes rolebinding or clusterrolebinding with the name of a group that you specify in the aws-auth ConfigMap.


To add an IAM user or role to an Amazon EKS cluster

1. Determine which credentials kubectl is using to access your cluster. On your computer, you can see which credentials kubectl uses with the following command. Replace ~/.kube/config with the path to your kubeconfig file if you don't use the default path.


2. Make sure that you have existing Kubernetes roles and rolebindings or clusterroles and clusterrolebindings that you can map IAM users or roles to. For more information about these resources, see Using RBAC Authorization in the Kubernetes documentation.
View your existing Kubernetes roles or clusterroles. Roles are scoped to a namespace, but clusterroles are scoped to the cluster.


3. Edit the aws-auth ConfigMap. You can use a tool such as eksctl to update the ConfigMap or you can update it manually by editing it.

* **Apply the aws-authConfigMap to your cluster**

1. **Using MapRoles**

The MapRoles field in the aws-auth ConfigMap is used to specify the IAM roles that should be mapped to a particular group in the cluster. This can be used to give certain IAM roles access to a specific group of resources within the cluster.

2. **Using MapUsers**

This is another way of providing access directly to the IAM users instead of AssumedRoles. This is relatively easy but also a bit cluttered and not usually an organized practice, as the number of users increases, it will also add more lines to the aws-auth ConfigMap making it more messy. Also, using AssumedRole is much more secure way of communicating with the cluster than directly using the IAM user, as the temporary credentials give you access to the cluster only for a limited time until you regenerate the token.


**Define Remote State Data Source:** `c2-remote-state-datasource.tf`
```
# Kubernetes Resource: Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: dev

```



**Define Remote State Data Source:** `c2-remote-state-datasource.tf`
```
# Kubernetes Resource: Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dev-ns-role
  namespace: dev
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]
---
# Kubernetes Resource: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-ns-rolebinding
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dev-ns-role
subjects:
- kind: Group
  namespace: dev
  name: eks-developer-group

```




**Define Remote State Data Source:** `c2-remote-state-datasource.tf`
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: eksdeveloper-clusterrole
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  - namespaces
  - pods
  - events
  verbs:
  - get
  - list
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - statefulsets
  - replicasets
  verbs:
  - get
  - list
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: eksdeveloper-clusterrolebinding
roleRef:
  kind: ClusterRole
  name: eksdeveloper-clusterrole
  apiGroup: rbac.authorization.k8s.io  
subjects:
- kind: Group
  name: eks-developer-group
  apiGroup: rbac.authorization.k8s.io


```






