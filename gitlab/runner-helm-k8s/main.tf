resource "aws_s3_bucket" "cache_bucket" {
  bucket = var.cache_bucket_name
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "null_resource" "configure_kubeconfig" {

  provisioner "local-exec" {

    command = "aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${var.region}"
  }
}

resource "kubernetes_namespace" "gitlab-runner" {
  metadata {
    name = "gitlab-runner"
  }
}

resource "kubernetes_secret" "s3access" {
  metadata {
    name = "s3access"
    namespace  = "gitlab-runner"
  }

  data = {
    accesskey = var.cache_bucket_access_key
    secretkey = var.cache_bucket_secret_key
  }

  depends_on = [
    null_resource.configure_kubeconfig,
    kubernetes_namespace.gitlab-runner
  ]
}

resource "helm_release" "gitlab-runner" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = "0.33.1"

  namespace  = "gitlab-runner"

  values = [
    templatefile("${path.module}/gitlab-runner-values.yaml", { cache_bucket_name = "${var.cache_bucket_name}", region = "${var.region}" })
  ]

  set_sensitive {
    name  = "runnerRegistrationToken"
    value = var.runner_registration_token
  }

  depends_on = [
    aws_s3_bucket.cache_bucket,
    kubernetes_secret.s3access
  ]

}