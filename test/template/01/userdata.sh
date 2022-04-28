#!/bin/bash -xe
yum update -y

amazon-linux-extras install docker=${DOCKER_VERSION}  -y
amazon-linux-extras install ansible2=${ANSIBLE_VERSION} -y
yum install -y zip unzip