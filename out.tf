output "default_vpc_cidr" {
  value = module.ec2.default_vpc_cidr
}
output "cp_ip" {
  value = module.ec2.cp_public_ip
}

# output "wn_public_ip" {
#   value = module.ec2.wn_public_ip
# }

output "elastic_ip" {
  value = module.ec2.elastic_ip
}

