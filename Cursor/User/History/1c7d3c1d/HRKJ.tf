resource "aws_instance" "webserver" {
  ami                     = var.webserver_ami
  instance_type           = var.webserver_instance_type
  key_name                = var.webserver_key_name
  # Attach the managed SG plus any extra IDs provided via variable.
  vpc_security_group_ids  = concat(var.webserver_vpc_security_group_ids, [aws_security_group.webserver_sg.id])
  disable_api_termination = var.webserver_disable_api_termination 
  # count                   = var.webserver_count

    user_data = <<-EOF
                  #!/bin/bash
                  sudo apt update -y
                  sudo apt install nginx -y
                  cat <<HTML >/var/www/html/index.html
                  <html>
                  <h1> Hi Avi <h1>
                  <h2> Welcome to Nginx webserver <h2>
                  <html>
                  HTML
                 
                  systemctl restart nginx
                  systemctl enable nginx
                  EOF


}



resource "aws_security_group" "webserver_sg" {
  name        = "webserver-sg"
  description = "Allow HTTP and SSH for webserver"
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
data "aws_ami" "data_webserver_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [ "amazon"] # Amazon

}

data "aws_instance" "data_webserver_instance" {
  instance_id = "i-07b89386252afb344"
  }
