output "k3s_endpoint" {
  value = module.kube-hetzner.k3s_endpoint
}

output "lb_control_plane_ipv4" {
  value = module.kube-hetzner.lb_control_plane_ipv4
}

output "nat_router_ipv4" {
  value = module.kube-hetzner.nat_router_public_ipv4
}

output "ingress_ipv4" {
  value = module.kube-hetzner.ingress_public_ipv4
}

output "network_id" {
  value = module.kube-hetzner.network_id
}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}