# 04 - Talos Cluster

Kubernetes runs on [Talos Linux](https://www.talos.dev/). Cloud control planes boot from a Hetzner-hosted Talos ISO and receive their machine config via `user_data` on first boot. The bare-metal worker is installed manually once via the Hetzner rescue system.

## Architecture

| Node       | Role         | Location | IP (private) | IP (WireGuard) |
| ---------- | ------------ | -------- | ------------ | -------------- |
| talos-cp-1 | controlplane | nbg1     | 10.20.0.10   | 10.25.0.3      |
| talos-cp-2 | controlplane | fsn1     | 10.20.0.11   | 10.25.0.4      |
| talos-cp-3 | controlplane | hel1     | 10.20.0.12   | 10.25.0.5      |
| talos-w-1  | worker       | fsn1     | 10.20.1.10   | 10.25.0.6      |

## One-Time Manual Prep

### vSwitch (Robot)

1. Create a vSwitch in [Hetzner Robot](https://robot.hetzner.com) → Servers → vSwitch → Create.
2. Attach the dedicated server to it.
3. Note the numeric vSwitch ID and set it in `terraform.tfvars`:
   ```hcl
   vswitch_id = 81327
   ```

### Bare-Metal Worker (Rescue System)

1. Boot the dedicated server into the Hetzner rescue system.
2. Write the Talos metal image to disk:
   ```bash
   wget -O /tmp/talos.raw.xz https://github.com/siderolabs/talos/releases/download/v1.13.0/metal-amd64.raw.xz
   xz -d -c /tmp/talos.raw.xz | dd of=/dev/nvme0n1 bs=4M status=progress && sync
   reboot
   ```
3. The server reboots into Talos maintenance mode on its public IP, port 50000.

### Laptop WireGuard Key

Generate a keypair and add the public key to `terraform.tfvars` before `tofu apply`. See [WireGuard setup](03-wireguard.md).

## Apply

```bash
export HCLOUD_TOKEN=...
export CLOUDFLARE_API_TOKEN=...
export TF_VAR_cloudflare_api_token=$CLOUDFLARE_API_TOKEN

cd opentofu/infrastructure
tofu init -backend-config=backend.hcl
tofu apply
```

OpenTofu:
- Creates the Hetzner Cloud network, subnets, vSwitch coupling, and firewall
- Boots three CPX22 VMs from the Hetzner Talos ISO with machine config injected via `user_data`
- Generates WireGuard keys for every node; the laptop public key is embedded in each node's config
- Pushes Talos machine config to the bare-metal worker via its public IP
- Bootstraps etcd on the first control plane
- Deploys Cilium, cert-manager, and external-dns via Helm

## Get Credentials

```bash
tofu output -raw kubeconfig              > ~/.kube/homelab.config
tofu output -raw talosconfig             > ~/.talos/config
tofu output -raw wireguard_laptop_config > ~/.config/wireguard/homelab.conf
# Edit homelab.conf — replace REPLACE_WITH_LAPTOP_PRIVATE_KEY with your laptop private key
```

## Verify

```bash
sudo wg-quick up ~/.config/wireguard/homelab.conf   # or via Mac App
KUBECONFIG=~/.kube/homelab.config kubectl get nodes
talosctl --talosconfig ~/.talos/config health --nodes 10.25.0.3
```

All nodes should be `Ready`. etcd and Cilium should be healthy.

## Lock Down the Firewall

During bootstrap, TCP 50000 (Talos API) and 6443 (kube-apiserver) are open publicly so OpenTofu can push machine config. Once WireGuard is verified, close them:

1. Set `bootstrap_complete = true` in `terraform.tfvars`.
2. `tofu apply` — only the firewall rules change.

After this, the cluster is reachable only over WireGuard.

## Tear Down

```bash
tofu destroy
```

The Hetzner Cloud network has `delete_protection = true` — disable it in the Hetzner Cloud Console first or destroy will fail.
