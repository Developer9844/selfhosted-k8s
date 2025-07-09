module "ec2" {
  source = "./modules/ec2"
  ingress_rules = var.ingress_rules
  ingress_rules_worker = var.ingress_rules_worker
}