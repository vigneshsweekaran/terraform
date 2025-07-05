variable "bucket_prefix" {
  type        = set(string)
  description = "list of s3 bucket name prefix"
  default     = ["bucket-1-", "bucket-2-", "bucket-3-"]
}