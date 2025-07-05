module "simple_bucket" {
  for_each = var.bucket_prefix
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket_prefix = each.value
}