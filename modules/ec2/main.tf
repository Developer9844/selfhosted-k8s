data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "instance_1" {
  ami           = "ami-0e001c9271cf7f3b9"
  instance_type = "t3.medium"
  key_name      = "new-server"
  count         = 1
  vpc_security_group_ids = [aws_security_group.securityGroup.id]
  depends_on = [ aws_security_group.securityGroup ]
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  user_data = file("${path.module}/../../scripts/master_node.sh")
  tags = {
    Name = "CP-Node"
  }
}

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.instance_1[0].id
}

# security group
resource "aws_security_group" "securityGroup" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name                     = "CP-security-group"
  }
  dynamic "ingress" {
    for_each = var.ingress_rules
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


# resource "aws_instance" "instance_2" {
#   ami           = "ami-0e001c9271cf7f3b9"
#   instance_type = "t3.medium"
#   key_name      = "new-server"
#   count         = 2
#   vpc_security_group_ids =  [aws_security_group.securityGroupWorker.id]
#   depends_on = [ aws_security_group.securityGroupWorker ]
#   root_block_device {
#     volume_size = 30
#     volume_type = "gp3"
#   }
#   user_data = file("${path.module}/../../scripts/containerd.sh")

#   tags = {
#     Name = "Worker-Node"
#   }
# }



# # security group
# resource "aws_security_group" "securityGroupWorker" {
#   vpc_id = data.aws_vpc.default.id

#   tags = {
#     Name                     = "Worker-security-group"
#   }
#   dynamic "ingress" {
#     for_each = var.ingress_rules_worker
#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#       description = ingress.value.description
#     }
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_vpc_security_group_egress_rule" "egress_rule_ipv4" {
#   security_group_id = aws_security_group.securityGroup.id
#   ip_protocol       = -1
#   cidr_ipv4         = "0.0.0.0/0"
# }

# resource "aws_vpc_security_group_egress_rule" "egress_rule_ipv4_worker" {
#   security_group_id = aws_security_group.securityGroupWorker.id
#   ip_protocol       = -1
#   cidr_ipv4         = "0.0.0.0/0"

# }