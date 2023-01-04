#Am going to create a ec2-machine in aws and my provider is AWS
#am adding variable i created from my terraform.tfvars
#now i need to create a ec2-machine
#create vpc
#create an aws_s3_bucket
#create private subnet
#create public subnet
# Creating RT for Private Subnet
# Creating RT for Public Subnet
#Associating the Public RT with the Public Subnets
#Associating the Private RT with the Private Subnets
# Create Internet Gateway resource and attach it to the VPC
# Create EIP for the IGW
# Create NAT Gateway resource and attach it to the VPC
#creating security group



#Am going to create a ec2-machine in aws and my provider is AWS

provider "aws" {
  region = "us-east-1"
}

 #am adding variable i created from my terraform.tfvars
variable "subnet_cidr_block" {
  description = "subnet cidr block"
}
variable "vpc-cidr" {
  description = "vpc cidr"

}
variable "bucket_prefix" {
  type    = string
  default = "bucketobj"

}
locals {
  bucket_name = var.bucket_prefix
}
#now i need to create an ec2-machine
resource "aws_instance" "webserver" {
  ami           = "ami-0b0dcb5067f052a63"
  instance_type = "t2.micro"
  tags = {
    "Name" = "webserver"
  }

}
#create vpc
resource "aws_vpc" "acthealth_dev" {
  cidr_block = var.vpc-cidr
  tags = {
    "Name" = "acthealth_dev"
  }

}
#create bucket with local variables
/*locals {
  bucket_name ="mytesting-cnl34"
  env         ="ddev"
  
}
resource "aws_s3_bucket" "bucket_tesst" {
  bucket = local.bucket_name
  acl    ="public-read-write"

  tags ={
    Name        = local.bucket_name
    enviroment  = local.env
  }
  
}*/
#create s3bhcket with variables prefix


#create an aws_s3_bucket 
resource "aws_s3_bucket" "tesstbucket356" {
  bucket = local.bucket_name
  acl    = "public-read-write"

}

#create private subnet
resource "aws_subnet" "myprivatesubnet" {
  vpc_id     = aws_vpc.acthealth_dev.id
  cidr_block = "10.0.2.0/24"
}
#create public subnet
resource "aws_subnet" "mypublicsubnet" {
  vpc_id     = aws_vpc.acthealth_dev.id
  cidr_block = var.subnet_cidr_block
}
# Creating RT for Private Subnet

resource "aws_route_table" "privRT" {
  vpc_id = aws_vpc.acthealth_dev.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW.id
  }
}

# Creating RT for Public Subnet
resource "aws_route_table" "publRT" {
  vpc_id = aws_vpc.acthealth_dev.id
  route {
    cidr_block = var.subnet_cidr_block
    gateway_id = aws_internet_gateway.IGW.id
  }
}
#Associating the Public RT with the Public Subnets
resource "aws_route_table_association" "PubRTAss" {
  subnet_id      = aws_subnet.mypublicsubnet.id
  route_table_id = aws_route_table.publRT.id
}
#Associating the Private RT with the Private Subnets
resource "aws_route_table_association" "PriRTAss" {
  subnet_id      = aws_subnet.myprivatesubnet.id
  route_table_id = aws_route_table.privRT.id
}
# Create Internet Gateway resource and attach it to the VPC

resource "aws_internet_gateway" "IGW" {

  vpc_id = aws_vpc.acthealth_dev.id

}

# Create EIP for the IGW

resource "aws_eip" "myEIP" {
  vpc = true
}

# Create NAT Gateway resource and attach it to the VPC
resource "aws_nat_gateway" "NAT-GW" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.mypublicsubnet.id
}
#creating security group
resource "aws_security_group" "allow_tls" {
  vpc_id      = aws_vpc.acthealth_dev.id
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

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
output "vpc-id" {
  value = "aws_vpc.acthealth_dev.id"
  
}
output "publicsubnet" {
  value = "aws_subnet.mypublicsubnet.id"
  
}
output "eip-id" {
  value = "aws_eip.myEIP.id"
  
}

#create public subnet associate with InternetGateWay
/*resource "aws_subnet" "acthealth_dev_public" {
  vpc_id     = aws_vpc.acthealth_dev.id
  
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.IGW.id

    
    tags = {
      Name = "acthealth_dev_public"
  
   }
  
}
#create public subnet associate with NatGateWay
resource "aws_subnet" "acthealth_dev_private" {
  vpc_id     = aws_vpc.acthealth_dev.id
 
    cidr_block = "10.0.2.0/24"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  
    tags = {
      Name = "acthealth_dev_private"
   
  }
}
resource "aws_nat_gateway" "nat-gateway" {
  vpc_id = aws_vpc.acthealth_dev.id
  
}

# Creating RT for Public Subnet
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.acthealth_dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}
# Creating RT for Private Subnet
resource "aws_route_table" "route-private" {
  vpc_id = aws_vpc.acthealth_dev.id

  route {
    cidr_block = "0.0.0.0/0"
    allocation_id = aws_eip.myEIP.id
    nat_gateway_id = aws_nat_gateway.natGW.id
  }

  
}

#Associating the Public RT with the Public Subnets
resource "aws_route_table_association" "pub-associate-sub-rou" {
  subnet_id      = aws_route_table.route-public.id
  route_table_id = aws_route_table.route-public.id
}
#Associating the Private RT with the Private Subnets
resource "aws_route_table_association" "pri-associate-sub-rou" {
  subnet_id      =aws_subnet.acthealth_dev_private.id
  route_table_id = aws_route_table.route-private.id
}
#create internet_gateway
resource "aws_internet_gateway" "IGW" {

  vpc_id = aws_vpc.acthealth_dev.id

}
#create aws_eip
resource "aws_eip" "myEIP" {
    vpc = true
  
}
#create a nat_gateway
/*resource "aws_nat_gateway" "natGW" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.acthealth_dev_public.id

  tags = {
    Name = "gw NAT"
  }
}*/