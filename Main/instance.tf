#terraform {
#  backend "s3" {
#    bucket          = "S3 bucket name here"
#    key             = "The 'Path' where the remote terraform.tfstate file is stored within the bucket declared above"
#    region          = "AWS Region here"
#    dynamodb_table  = "Dynamo DB table name here"
#    encrypt         = true
#  }
#}

resource "aws_instance" "public" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.main.outputs.public-subnet
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  key_name               = "mykey"

    tags = {
      Name = "public-instance"
  }
}

resource "aws_security_group" "public-sg" {
  name   = "public-sg"
  vpc_id = data.terraform_remote_state.main.outputs.vpc-id

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

  tags = {
    Name = "public-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
