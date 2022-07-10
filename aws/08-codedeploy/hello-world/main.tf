data "aws_ami" "amazonlinux2" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-gp2"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "hello-world" {
    instance_type = "t2.micro"
    ami = data.aws_ami.amazonlinux2.id

    tags = {
        Name = "HelloWorld"
        Environment = "dev"
    }
}