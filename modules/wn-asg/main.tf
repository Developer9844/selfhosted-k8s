# security group
resource "aws_security_group" "securityGroupWorker" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "Worker-security-group"
  }
  dynamic "ingress" {
    for_each = var.ingress_rules_worker
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "LaunchTemplate" {
  name_prefix   = "Launch-Template"
  image_id      = "ami-0e001c9271cf7f3b9"
  instance_type = "t3.medium"
  key_name      = "new-server"

  user_data = base64encode(file("${path.module}/../../scripts/worker_node.sh"))

  vpc_security_group_ids = [aws_security_group.securityGroupWorker.id]
  block_device_mappings {
    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
    device_name = "/dev/sdf"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"] 
  }
}

resource "aws_autoscaling_group" "AutoScalingGroup" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.LaunchTemplate.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Worker-node"
    propagate_at_launch = true
  }
}

