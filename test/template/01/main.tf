data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh")
  vars = {
    DOCKER_VERSION             = var.DOCKER_VERSION
    ANSIBLE_VERSION            = var.ANSIBLE_VERSION
  }
}

# To use the rendered contenet
#resource "aws_launch_configuration" "bitslovers-lc" {
#  name_prefix          = "${var.my_environment_name}-lc-"
#  image_id             = "ami-12345"
#  instance_type        = var.INSTANCE_TYPE
#  security_groups      = [aws_security_group.inst.id]
#  user_data            = data.template_file.userdata.rendered
#  key_name             = "bitslovers-keypair"
#  iam_instance_profile = aws_iam_instance_profile.iam_profile.name
#}