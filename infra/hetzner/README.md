# Hetzner k3s Cluster

Terraform configuration for a k3s Kubernetes cluster on Hetzner Cloud using the [kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner) module.

## Architecture

- 1 control plane node (cx23, IPv4 only)
- 1 worker node (cx23, no public IP)
- Dedicated NAT router for worker outbound traffic
- Load balancer for control plane API access (port 6443)
- Hetzner Cloud Firewall — SSH and kube API restricted to `allowed_ips`, HTTP/HTTPS open to all
- Private network `10.0.0.0/16` in `eu-central`

## Prerequisites

### Tools

```bash
# Fedora/RHEL
sudo dnf install terraform packer kubectl

# macOS
brew install hashicorp/tap/terraform hashicorp/tap/packer kubectl
```

### Hetzner setup

1. Create a Hetzner Cloud project and generate a Read & Write API token
2. Create an Object Storage bucket for Terraform state and update `backend.tf`
3. Generate an SSH keypair:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/hetzner_k3s -N ""
```

### Build MicroOS snapshot (one-time per Hetzner project)

kube-hetzner requires openSUSE MicroOS as the node OS. Build it with Packer before the first apply:

```bash
terraform init

export HCLOUD_TOKEN="your-token"
cd .terraform/modules/kube-hetzner/packer-template
packer init hcloud-microos-snapshots.pkr.hcl
packer build hcloud-microos-snapshots.pkr.hcl
cd -
```

## Usage

1. Copy the example vars file and fill in your values:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Export credentials:
```bash
export AWS_ACCESS_KEY_ID=<hetzner-s3-access-key>
export AWS_SECRET_ACCESS_KEY=<hetzner-s3-secret-key>
```

3. Deploy:
```bash
terraform init
terraform plan
terraform apply
```

4. Access the cluster:
```bash
terraform output -raw kubeconfig > k3s_kubeconfig.yaml
export KUBECONFIG=$(pwd)/k3s_kubeconfig.yaml
kubectl get nodes
```

## Variables

| Name | Description | Sensitive |
|---|---|---|
| `hcloud_token` | Hetzner Cloud API token | yes |
| `ssh_private_key` | Private key for node SSH access | yes |
| `ssh_public_key` | Corresponding public key | no |
| `allowed_ips` | IPs allowed to access SSH and kube API | no |

## Outputs

| Name | Description |
|---|---|
| `k3s_endpoint` | Kubernetes API endpoint |
| `lb_control_plane_ipv4` | Load balancer public IP (kubectl access) |
| `nat_router_ipv4` | NAT router public IP |
| `ingress_ipv4` | Ingress public IP (for DNS) |
| `network_id` | Private network ID |
| `kubeconfig` | Cluster kubeconfig (sensitive) |

## GitHub Actions

Workflows are included in `.github/workflows/`:

| Workflow | Trigger | Description |
|---|---|---|
| `bootstrap.yml` | Manual | Builds MicroOS snapshot (run once) |
| `infra.yml` | PR / Manual | Plan on PR, apply or destroy manually |

Required repository secrets/variables:

| Name | Type | Description |
|---|---|---|
| `HCLOUD_TOKEN` | Secret | Hetzner Cloud API token |
| `HETZNER_S3_ACCESS_KEY_ID` | Secret | Object storage access key |
| `HETZNER_S3_SECRET_ACCESS_KEY` | Secret | Object storage secret key |
| `SSH_PRIVATE_KEY` | Secret | Private key contents |
| `SSH_PUBLIC_KEY` | Secret | Public key contents |
| `ALLOWED_IPS` | Variable | JSON array e.g. `["1.2.3.4/32"]` |
