terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.13.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

#############################################################
resource "aws_vpc" "my_vpc" { 
  cidr_block			= "11.0.0.0/16"
  instance_tenancy  		= "default"
  enable_dns_hostnames		= "true"
  enable_dns_support		= "true"
   
  tags = {
      Name = "vpc-my_vpc"
  }
} 

resource "aws_route_table" "route_table" {
  vpc_id 			= aws_vpc.my_vpc.id
  
  tags = {
      Name = "rtb-my_vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id      			= aws_vpc.my_vpc.id
  cidr_block			= "11.0.11.0/24"
  availability_zone		= "us-east-2a"
  map_public_ip_on_launch 	= "true"

  tags = {
      Name = "pubic-sub1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id      			= aws_vpc.my_vpc.id
  cidr_block			= "11.0.12.0/24"
  availability_zone		= "us-east-2b"
  map_public_ip_on_launch 	= "true"

  tags = {
      Name = "public-sub2"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id      			= aws_vpc.my_vpc.id
  cidr_block			= "11.0.13.0/24"
  availability_zone		= "us-east-2c"
  map_public_ip_on_launch 	= "true"

  tags = {
      Name = "public-sub3"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id 			= aws_vpc.my_vpc.id
  
  tags = {
      Name = "igw-vpc"
  }
}


resource "aws_main_route_table_association" "vpc_association" {
  vpc_id         = aws_vpc.my_vpc.id
  route_table_id = aws_route_table.route_table.id
}


resource "aws_route_table_association" "subnet_association_1" {
   subnet_id	  = aws_subnet.subnet_1.id
   route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_association_2" {
   subnet_id	  = aws_subnet.subnet_2.id
   route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_association_3" {
   subnet_id	  = aws_subnet.subnet_3.id
   route_table_id = aws_route_table.route_table.id
}
resource "aws_security_group" "sg_1" {
  name        = "my_vpc"
  description = "From Terraform"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = ""
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = ""
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = ""
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = ""
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-1"
  }
}
