locals {
  key_name         = "jenkins"
  private_key_path = "~/.ssh/id_rsa"
}

data "aws_region" "current" {}

resource "aws_key_pair" "jenkins" {
  key_name = local.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allow http inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_jenkins"
  }
}

resource "aws_instance" "jenkins" {
  instance_type          = "t2.medium"
  ami                    = "ami-0d70546e43a941d70"
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Verified ssh connection'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local.private_key_path)
      host        = aws_instance.jenkins.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook  -i ${aws_instance.jenkins.public_ip}, --private-key ${local.private_key_path} playbook.yaml"
  }

  tags = {
    Name        = "Jenkins"
  }
}
