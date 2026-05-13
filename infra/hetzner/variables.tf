variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "allowed_ips" {
  type        = list(string)
  description = "IPs allowed to access SSH and the Kubernetes API"
}
