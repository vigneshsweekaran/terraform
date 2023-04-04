variable "enable_additiona_files" {
  type        = bool
  default     = false
}

variable "additional_files" {
  description = "File name and content"
  type = map(string)
}