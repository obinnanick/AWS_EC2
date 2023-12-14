terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
    }
  }
}
#configuring the AWS provider
provider "aws" {
  region ="us-east-1"
}
resource "aws_vpc" "webA" {
    tags = {
      Name = "webA_VPC"
    }
    cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.webA.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.webA.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
}
resource "aws_security_group" "webA_SG" {
    tags ={
        Name = "webA_SG"
    }
    vpc_id = aws_vpc.webA.id
    description = "allow inbound SSH and HTTP traffic"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "web-server" {
    ami = "ami-0230bd60aa48260c6"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    key_name = "A4L"
    security_groups = [aws_security_group.webA_SG.id]
    tags = {
      Name = "webA_EC2"
    }

  
}