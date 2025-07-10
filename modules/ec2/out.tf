output "cp_public_ip" {
  value = aws_instance.instance_1[0].public_ip
}

output "wn_public_ip" {
  value = [aws_instance.instance_2[0].public_ip, aws_instance.instance_2[1].public_ip]
}
output "default_vpc_id" {
  value = data.aws_vpc.default.id
}
output "default_vpc_cidr" {
  value = data.aws_vpc.default.cidr_block
}
output "elastic_ip" {
  value = aws_eip.elastic_ip.address
}


