resource "aws_elb" "my-elb" {
  name 				= "my-elb"
  subnets 			= [data.terraform_remote_state.main.outputs.public-subnet, data.terraform_remote_state.main.outputs.public-subnet-2]
  security_groups		= [aws_security_group.elb-sg.id]
  internal			= "false"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_security_group" "elb-sg" {
  vpc_id      = data.terraform_remote_state.main.outputs.vpc-id
  name        = "elb-sg"
    
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "my-elb"
  }
}

#data "terraform_remote_state" "main" {
#  backend = "s3"
#    
#    config = {
#      bucket          = "Bucket where Global terraform.tfstate is stored"
#      key             = "The 'Path' where the Global terraform.tfstate is stored"
#      region          = "AWS Region"
#  }
#}
