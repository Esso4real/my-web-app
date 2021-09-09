terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
} 

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA5JCZD7CVAM7WFGZA"
  secret_key = "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"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "My ProjectA VPC"
  }
}

# Create a Subnet
resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"

tags = {
    "Name" = "My ProjectA Subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My ProjectA IGW"
  }
}

# My securty Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
      description      = "TLS from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "allow_tls"
  }
}

# Create Route Table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.my_igw.id
    }

  tags = {
    Name = "My ProjectA RT"
  }
}

# Create Route Table Association
resource "aws_route_table_association" "my_rta" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# Create AMI dynamically
data "aws_ami" "my_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  } 

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
}

# Create Key-pair automatically 
/* resource "aws_key_pair" "my_kp" {
    key_name = "keypair"
    public_key = "${file("/Users/new/.ssh/id_rsa.pub")}"
}    
*/
#Create EC2 Instance
resource "aws_instance" "my_instance" {
    ami = data.aws_ami.my_ami.id
    instance_type = "t2.micro" 
    

    subnet_id = aws_subnet.my_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_tls.id]

    associate_public_ip_address = true
    key_name = "keypair"

    /*user_data = <<EOF

                  #!/bin/bash
                  sudo echo "pass123" | passwd --stdin ec2-user ye
                  sudo yum update && sudo yum install docker -y
                  sudo systemctl start docker 
                  sudo systemctl enabled docker 
                  sudo chmod 666 /var/run/docker.sock
                  sudh usermod -aG docker ec2-user                  
                  echo "coco4real@001" | docker login -u esso4real --password-stdin

                  EOF */
 
           

    tags = {
      "Name" = "My_EC2_instance"
    }
  
}
output "ec2_public_ip" {
    value = aws_instance.my_instance.public_ip
  
}
