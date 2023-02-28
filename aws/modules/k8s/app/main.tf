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

resource "kubernetes_deployment" "app" {
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
            container_port = 8082
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

resource "kubernetes_service" "app" {
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
      target_port = 8082
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}

resource "kubernetes_ingress" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = var.healthcheck_path
      "alb.ingress.kubernetes.io/healthcheck-port" = var.healthcheck_port
      "alb.ingress.kubernetes.io/certificate-arn"  = var.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"     = var.listen_ports
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = var.ssl_redirect
    }
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
            service_name = kubernetes_service.app.metadata[0].name
            service_port = kubernetes_service.app.spec[0].port[0].port
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}
