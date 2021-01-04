terraform {
  required_providers {
    aws       = {
      source  = "hashicorp/aws"
      version = "3.13.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  user_data = <<EOF
#!/bin/bash
sleep 30s
sudo apt-get -y update && apt-get -y install python && apt-get -y install python-pip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker
usermod -aG docker ubuntu
sudo apt-get update -y
sudo apt install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y
usermod -aG docker jenkins
EOF
}

#############################################################

resource "aws_instance" "test-instance" {
   count                            = "1" 
   ami                              = "ami-0dd9f0e7df0f0a138"
   tenancy                          = "default"
   associate_public_ip_address      = true 
   availability_zone                = "us-east-2a"
   key_name                         = "indrakey"
   instance_type                    = "t2.medium" 
   monitoring                       = true

   subnet_id                        = "subnet-079e83aeeb6758e96" //subnet VPC
   vpc_security_group_ids           = [
            "sg-016ef4528278ccd30"                               //Security group VPC
       ]
   
   tags = {
     		Name	= "test-jenkins"
        } 
           
   root_block_device {
           delete_on_termination 	  = true 
           volume_size           	  = 20 
           volume_type           	  = "gp2" 
        }
   user_data_base64                 = base64encode(local.user_data)
}
