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
apt-get -y update && apt-get -y install python && apt-get -y install python-pip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker
usermod -aG docker ubuntu
apt-get install nginx -y
systemctl enable nginx.service
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa <<< y
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
   instance_type                    = "t2.micro" 
   monitoring                       = true

   subnet_id                        = "subnet-079e83aeeb6758e96" //subnet VPC
   vpc_security_group_ids           = [
            "sg-016ef4528278ccd30"                               //Security group VPC
       ]
   
   tags = {
     		Name	= "test-instance"
        } 
           
   root_block_device {
           delete_on_termination 	  = true 
           volume_size           	  = 10 
           volume_type           	  = "gp2" 
        }
   user_data_base64                 = base64encode(local.user_data)
}
