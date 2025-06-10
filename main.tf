####### Variables #######

variable "ami_id" {
  description = "ID de la AMI para la instancia EC2"
  default     = "ami-0440d3b780d96b29d"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  default     = "t3.micro"
}

variable "server_name" {
  description = "Nombre del servidor web"
  default     = "nginx-server"
}

variable "environment" {
  description = "Ambiente de la aplicación"
  default     = "test"
}





####### provider #######
provider "aws" {
  region = "us-east-1"
}


#######  resource ####### 
resource "aws_instance" "nginx-server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.nginx-server-ssh.key_name

    user_data = <<-EOF
            #!/bin/bash
            sudo yum install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx
            EOF

   vpc_security_group_ids = [
	aws_security_group.nginx-server-sg.id
  ]

  tags = {
    Name        = var.server_name
    Environment = "prod"
    Owner       = "juan-guevara@uce.edu.ec"
    Team        = "DevOps"
    Project     = "UCE"
  }


  }

  resource "aws_key_pair" "nginx-server-ssh" {
  key_name   = "nginx-server-ssh"
  public_key = file("${var.server_name}.key.pub")
    tags = {
        Name        = var.server_name
        Environment = "prod"
        Owner       = "juan-guevara@uce.edu.ec"
        Team        = "DevOps"
        Project     = "UCE"
    }

  }

  ####### SG ####### 
resource "aws_security_group" "nginx-server-sg" {
  name        = "nginx-server-sg"
  description = "Security group allowing SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    tags = {
    Name        = var.server_name
    Environment = "prod"
    Owner       = "juan-guevara@uce.edu.ec"
    Team        = "DevOps"
    Project     = "UCE"
  }

}

#######  output ####### 
output "server_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.nginx-server.public_ip
}

output "server_public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.nginx-server.public_dns
}