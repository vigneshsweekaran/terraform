locals {
  local_ingress_annotations = {
    "kubernetes.io/ingress.class"                = "alb"
    "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"      = "ip"
    "alb.ingress.kubernetes.io/group.name"       = "test"
    "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}]"
    "alb.ingress.kubernetes.io/healthcheck-path" = var.healthcheck_path
    "alb.ingress.kubernetes.io/healthcheck-port" = var.healthcheck_port    
  }
}

# resource "kubernetes_secret" "app" {
#   metadata {
#     name      = var.name
#     namespace = var.namespace
#     labels = {
#       environment = var.namespace
#       name = var.name
#     }
#   }

#   data = {
#     API_DB_HOST    = var.api_db_host
#     API_DB_UNAME   = var.api_db_uname
#     API_DB_UPASSWD = var.api_db_upasswd
#     API_DB_SCHEMA  = var.api_db_schema
#   }
# }

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      environment = var.namespace
      name        = var.name
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        environment = var.namespace
        name        = var.name
      }
    }

    template {
      metadata {
        labels = {
          environment = var.namespace
          name        = var.name
        }
      }

      spec {
        container {
          image = "${var.image_name}:${var.image_tag}"
          name  = var.name

          port {
            container_port = 80
          }

          # env_from {
          #   secret_ref {
          #     name = var.name
          #   }
          # }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    selector = {
      environment = var.namespace
      name        = var.name
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment_v1.app]
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = var.enable_lb_soureip ? merge(local.local_ingress_annotations, var.ingress_annotations_sourceip) : local.local_ingress_annotations
    labels = {
      environment = var.namespace
      name        = var.name
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service_v1.app.metadata[0].name
              port {
                number = kubernetes_service_v1.app.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service_v1.app]
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "app" {

  count = var.enable_hpa ? 1 : 0

  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    scale_target_ref {
      kind = "Deployment"
      name = var.name
    }
  }
}
