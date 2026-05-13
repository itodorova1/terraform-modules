module "kube-hetzner" {
  source  = "kube-hetzner/kube-hetzner/hcloud"
  version = "2.19.2"

  providers = {
    hcloud = hcloud
  }

  hcloud_token         = var.hcloud_token
  ssh_private_key      = var.ssh_private_key
  ssh_public_key       = var.ssh_public_key
  create_kubeconfig    = false
  create_kustomization = false

  network_region     = "eu-central"
  network_ipv4_cidr  = "10.0.0.0/16"
  ingress_controller = "none"

  firewall_ssh_source      = var.allowed_ips
  firewall_kube_api_source = var.allowed_ips

  extra_firewall_rules = [
    {
      description = "Allow HTTP"
      direction   = "in"
      protocol    = "tcp"
      port        = "80"
      source_ips  = ["0.0.0.0/0", "::/0"]
    },
    {
      description = "Allow HTTPS"
      direction   = "in"
      protocol    = "tcp"
      port        = "443"
      source_ips  = ["0.0.0.0/0", "::/0"]
    }
  ]

  use_control_plane_lb = true

  nat_router = {
    server_type = "cx23"
    location    = "nbg1"
  }

  control_plane_nodepools = [
    {
      name         = "control-plane"
      server_type  = "cx23"
      location     = "nbg1"
      count        = 1
      labels       = []
      taints       = []
      disable_ipv6 = true
    }
  ]

  agent_nodepools = [
    {
      name         = "worker"
      server_type  = "cx23"
      location     = "nbg1"
      count        = 1
      labels       = []
      taints       = []
      disable_ipv4 = true
      disable_ipv6 = true
    }
  ]
}
