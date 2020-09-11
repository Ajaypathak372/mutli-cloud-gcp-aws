resource "kubernetes_service" "svc" {
  metadata {
    name = var.svc_name
    labels = {
        app = var.app
    }
  }
  spec {
    selector = {
      app = var.app
      tier = var.tier
    }
    type  = "LoadBalancer"
    port {
      port        = var.port_no
    }
  }
  depends_on = [ google_container_node_pool.node_pool ]
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name = var.pvc_name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  depends_on = [ google_container_node_pool.node_pool ]
}

resource "kubernetes_deployment" "deploy" {
  metadata {
    name = var.deployment_name
    labels = {
      app = var.app
      tier = var.tier
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = var.app
        tier = var.tier
      }
    }

    template {
      metadata {
        labels = {
          app = var.app
          tier = var.tier
        }
      }

      spec {
        container {
          image = var.image_name
          name  = "wordpress"
          port   {
              name = "wordpress"
              container_port = var.port_no
          }
          volume_mount  {
              name = "wordpress-persistent-storage"
              mount_path = "/var/www/html"
          } 
          env {
            name = "WORDPRESS_DB_HOST"
            value = aws_db_instance.default.address 
          }
          env { 
            name = "WORDPRESS_DB_USER"
            value = var.userrds
          }
          env { 
            name = "WORDPRESS_DB_PASSWORD"
            value = var.passrds 
          } 
          env {
            name = "WORDPRESS_DB_NAME"
            value = var.db
          } 
        }
        volume  {
          name = "wordpress-persistent-storage"
          persistent_volume_claim { 
              claim_name = var.pvc_name 
          }
        }
      }
    }
  }
  depends_on = [ kubernetes_service.svc , kubernetes_persistent_volume_claim.pvc ]
}

output "ip" {
  value = kubernetes_service.svc.load_balancer_ingress.0.ip
}