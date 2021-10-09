resource "null_resource" "health_check" {

  provisioner "local-exec" {

    command = "aws eks update-kubeconfig --name ${var.eks_cluster_name}"
  }
}

resource "helm_release" "gitlab-runner" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = "0.33.1"

  namespace  = "gitlab-runner"
  create_namespace = true

  values = [
    file("${path.module}/gitlab-runner-values.yaml")
  ]

  set_sensitive {
    name  = "runnerRegistrationToken"
    value = var.runner_registration_token
  }

}