# Resource: MySQL Kubernetes Deployment
resource "kubernetes_deployment_v1" "mysql_deployment" {
  metadata {
    name = "mysql"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }          
    }
    strategy {
      type = "Recreate"
    }  
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = "ebs-mysql-pv-claim"
          }
        }
        volume {
          name = "usermanagement-dbcreation-script"
          config_map {
            name = kubernetes_config_map_v1.config_map.metadata.0.name 
          }
        }
        container {
          name = "mysql"
          image = "mysql:5.6"
          port {
            container_port = 3306
            name = "mysql"
          }
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = "dbpassword11"
          }
          volume_mount {
            name = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
          volume_mount {
            name = "usermanagement-dbcreation-script"
            mount_path = "/docker-entrypoint-initdb.d" #https://hub.docker.com/_/mysql Refer Initializing a fresh instance                                            
          }
        }
      }
    }      
  }
  
}