resource "aws_instance" "webserver" {
  ami                     = var.webserver_ami
  instance_type           = var.webserver_instance_type
  key_name                = var.webserver_key_name
  vpc_security_group_ids  = var.webserver_vpc_security_group_ids , data.aws_security_group.webserver_sg.id
  disable_api_termination = var.webserver_disable_api_termination 
  # count                   = var.webserver_count

  user_data = <<EOF 
  #!/bin/bash
  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "<h1>welcome to webserver</h1>" > /var/www/html/index.html
  EOF
}


resource "aws_security_group" "webserver_sg" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
       }


}


output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
  
}
output "webserver_public_dns" {
  value = aws_instance.webserver.public_dns
}
output "webserver_id" {
  value = aws_instance.webserver.id
}
output "webserver_sg_id" {
  value = aws_security_group.webserver_sg.id
}
output "webserver_sg_arn" {
  value = aws_security_group.webserver_sg.arn
}

data "aws_security_group" "webserver_sg" {
  name = "launch-wizard-1"
}

data "aws_ami" "webserver_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["ami-0f00d706c4a80fd93"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

data "aws_instance" "data_webserver_instance" {
  instance_id = "i-017d76c3caa44f6ba"
  }