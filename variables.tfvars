region      = "us-east-1"
aws_profile = "ankush-katkurwar30"
ingress_rules = {
  API_server = {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kubernetes API server"
  }
  etcd = {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]     # This is default vpc CIDR
    description = "for etcd database server client API on the private network only"
  }
  kubelet = {
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
    description = "kubelet, kube-scheduler, and kube-controller, also on private network only"
  }
  ssh = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from 0.0.0.0/0"
  }
}


ingress_rules_worker = {
  kubelet_api = {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
    description = "kubelet API server"
  }
  nodePort = {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for etcd database server client API on the private network only"
  }
  ssh = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from 0.0.0.0/0"
  }
}




