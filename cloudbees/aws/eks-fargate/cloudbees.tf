resource "kubernetes_namespace" "cloudbees" {
  metadata {
    name = local.namespace
  }
  
  depends_on = [
    module.eks
  ]
}

resource "kubernetes_persistent_volume_v1" "jenkins-0" {
  metadata {
    name = "jenkins-0"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = local.storage_class_name
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.cloudbees.id 
      }
    }
  }

  depends_on = [
    kubernetes_storage_class.efs
  ]
}

resource "kubernetes_persistent_volume_claim_v1" "jenkins-0" {
  metadata {
    name = "jenkins-home-cjoc-0"
    namespace = local.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = local.storage_class_name
    volume_name = "${kubernetes_persistent_volume_v1.jenkins-0.metadata.0.name}"
  }

  depends_on = [
    kubernetes_namespace.cloudbees,
    kubernetes_persistent_volume_v1.jenkins-0
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
    kubernetes_persistent_volume_claim_v1.jenkins-0   
  ]
}
