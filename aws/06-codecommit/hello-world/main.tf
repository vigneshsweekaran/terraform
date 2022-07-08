resource "aws_codecommit_repository" "hello-world" {
  repository_name = "hello-world"
  description     = "This is the hello-world java app"
}