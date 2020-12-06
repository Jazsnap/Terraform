#terraform {
#  backend "s3" {
#    bucket          = "S3 bucket name here"
#    key             = "The 'Path' where the remote terraform.tfstate file is stored within the bucket declared above"
#    region          = "AWS Region here"
#    dynamodb_table  = "Dynamo DB table name here"
#    encrypt         = true
#  }
#}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

  resource "aws_subnet" "private" {
  vpc_id     		    = aws_vpc.main.id
  cidr_block 		    = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Main-private"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.nat-access.id
}

  resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Main-private-2"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.nat-access.id
}

  resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone 	    = "eu-west-1a"

  tags = {
    Name = "Main-public"
  }
 }

  resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.internet-access.id
}

  resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone 	    = "eu-west-1b"

  tags = {
    Name = "Main-public-2"
  }
 }

  resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.internet-access.id
}

 resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "internet-access" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

  resource "aws_eip" "nat-gw" {
    vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat-gw.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw-NAT"
  }
}

resource "aws_route_table" "nat-access" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}
