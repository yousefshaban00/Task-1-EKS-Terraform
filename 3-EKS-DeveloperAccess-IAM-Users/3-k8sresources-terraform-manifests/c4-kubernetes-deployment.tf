# Kubernetes Deployment Manifest
resource "kubernetes_deployment_v1" "myapp1" {
  metadata {
    name = "myapp1-deployment"
    labels = {
      app = "myapp1"
    }
    namespace = "dev"
  } 
 
  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "myapp1"
      }
    }

    template {
      metadata {
        labels = {
          app = "myapp1"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "myapp1-container"
          port {
            container_port = 80
          }
          }
        }
      }
    }
}

