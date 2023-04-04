locals {
    files = {
        hello1 = "Hello world 1"
        india   = "Hello India"
    }
    total_files = var.enable_additiona_files ? merge(local.files, var.additional_files) : local.files
}

resource "local_file" "foo" {
  for_each = local.total_files

  content  = "${each.value}"
  filename = "${each.key}"
}