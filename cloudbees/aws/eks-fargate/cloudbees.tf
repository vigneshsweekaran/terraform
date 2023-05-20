resource "kubernetes_namespace" "cloudbees" {
  metadata {
    name = local.namespace
  }
  
  depends_on = [
    module.eks
  ]
}

resource "helm_release" "cloudbees" {
  name       = local.name
  repository = "https://public-charts.artifacts.cloudbees.com/repository/public"
  chart      = "cloudbees-core"
  version    = local.version

  namespace  = local.namespace

  values = [
    templatefile("${path.module}/values.yaml", { storage_class_name = "${local.storage_class_name}" })
  ]

   depends_on = [
    kubernetes_storage_class.efs
  ]
}
