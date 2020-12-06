resource "aws_autoscaling_policy" "scale-up" {
  name                   = "cpu-scale-up-policy"
  scaling_adjustment     = "1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "120"
  autoscaling_group_name = aws_autoscaling_group.my-asg.name
  policy_type		 = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale-up-alarm" {
  alarm_name                = "scale-up-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my-asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]
}


resource "aws_autoscaling_policy" "scale-down" {
  name                   = "cpu-scale-down-policy"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "120"
  autoscaling_group_name = aws_autoscaling_group.my-asg.name
  policy_type		 = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale-down-alarm" {
  alarm_name                = "scale-down-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "5"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my-asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]
}

resource "aws_launch_configuration" "private" {
  name			             = "my-launch-config"
  image_id               = data.terraform_remote_state.main.outputs.ami
  instance_type          = "t2.micro"
  security_groups        = [aws_security_group.private-sg.id]
  key_name               = "mykey"
  user_data		           = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`\necho 'this is: '$MYIP > /var/www/html/index.html"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "my-asg" {
  name                      = "my-asg"
  launch_configuration      = aws_launch_configuration.private.name
  min_size	                = 2
  max_size	                = 4
  vpc_zone_identifier       = [data.terraform_remote_state.main.outputs.private-subnet, data.terraform_remote_state.main.outputs.private-subnet-2]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers  	    = [aws_elb.my-elb.name]
  force_delete              = true
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "private-sg" {
  name        = "private-sg"
  vpc_id      = data.terraform_remote_state.main.outputs.vpc-id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}
