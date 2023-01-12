# This is my provider 
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#This is my VPC
resource "aws_vpc" "gabby-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "gabby"
  }
}
#This is my public subnet 
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.gabby-vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public"
  }
}
#This my security_group
resource "aws_security_group" "SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.gabby-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.gabby-vpc.cidr_block]

  }
#This aws were a i was having issue because i did not open port 80 to the incoming Traffic
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.gabby-vpc.cidr_block]

  }


  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.gabby-vpc.cidr_block]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#This is my RouteTable
resource "aws_route_table" "Rtable" {
  vpc_id = aws_vpc.gabby-vpc.id

  route = []

  tags = {
    Name = "Rtable"
  }
}

# This is my  route_table_association
resource "aws_route_table_association" "ATable" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.Rtable.id
}

#This is my intenet GateWay
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.gabby-vpc.id

  tags = {
    Name = "main"
  }
}

#This is my key.pem
resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
#This is my aws ec2-instance
resource "aws_instance" "my-web-server" {
  key_name      = aws_key_pair.my-key.key_name
  ami           = "ami-0fe472d8a85bc7b0e"
  instance_type = "t2.micro"


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo systemctl start nginx"
    ]
  }
}


