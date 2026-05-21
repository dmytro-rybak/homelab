# 03 - WireGuard

WireGuard is fully managed by OpenTofu. Node keys are generated automatically. The only manual step is generating your laptop keypair and adding the public key to tfvars before `tofu apply`.

## Generate Laptop Keypair (one-time)

```bash
wg genkey | tee ~/.config/wireguard/homelab.key | wg pubkey
```

Copy the public key into `opentofu/infrastructure/terraform.tfvars`:

```hcl
laptop_wireguard = {
  public_key = "<your-public-key>"
  address    = "10.25.0.100/32"
}
```

Keep the private key file — you'll need it in the next step.

## Get the Laptop Config

After `tofu apply`:

```bash
tofu output -raw wireguard_laptop_config > ~/.config/wireguard/homelab.conf
```

Replace the private key placeholder:

```bash
PRIVKEY=$(cat ~/.config/wireguard/homelab.key)
sed -i '' "s|REPLACE_WITH_LAPTOP_PRIVATE_KEY|$PRIVKEY|" ~/.config/wireguard/homelab.conf
```

## Bring Up the Tunnel

```bash
sudo wg-quick up ~/.config/wireguard/homelab.conf
```

Or import into the [WireGuard Mac App](https://apps.apple.com/app/wireguard/id1451685025) and toggle it on.

## Verify

```bash
sudo wg show
```

Each node should appear as a peer with a recent `latest handshake`.
