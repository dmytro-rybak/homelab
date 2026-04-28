# Homelab

## Proxmox

System Upgrade

```bash
apt update && apt full-upgrade
```

Disable SSH password, only key authentication is allowed

```bash
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

Set the root password

```bash
passwd
```

## Fix locale

Select `en_US.UTF-8` and set as default

```bash
dpkg-reconfigure locales
```

```bash
echo 'LC_CTYPE=en_US.UTF-8' >> /etc/environment
echo 'LANG=en_US.UTF-8' >> /etc/environment
```

## Disable IPv6

```bash
cat <<EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
sysctl -p
```

Verify no IPv6 addresses are assigned

```bash
ip addr | grep inet6
```

## Automatic security updates

```bash
apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades
```

## Wireguard

Generate server keys

```bash
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
chmod 600 /etc/wireguard/privatekey
```

Edit the Wireguard config

```bash
nano /etc/wireguard/wg0.conf
```

Server:

```ini
[Interface]
Address = 10.25.0.1/24
PrivateKey = <server_private_key>
ListenPort = 51820

# MacBook
[Peer]
PublicKey = <mac_public_key>
AllowedIPs = 10.25.0.2/32
```

MacBook:

```ini
[Interface]
Address = 10.25.0.2/24
PrivateKey = <mac_private_key>

[Peer]
PublicKey = <server_public_key>
Endpoint = <hetzner_server_ip>:51820
AllowedIPs = 10.25.0.0/24
PersistentKeepalive = 25
```

Bring the tunnel up (or restart it)

```bash
wg-quick up wg0
# or
wg-quick down wg0 && wg-quick up wg0
```

## Update local ssh config

```ini
# ~/.ssh/config
Host homelab
    HostName 10.25.0.1
    User root
    IdentityFile ~/.ssh/homelab
```

## Hetzner firewall

Now lock down Hetzner firewall — only allow:

| Protocol | Port  | Purpose   |
| -------- | ----- | --------- |
| UDP      | 51820 | WireGuard |
| ICMP     | -     | Ping      |

Open SSH if you mess with VPN to resolve issues:

| Protocol | Port  | Purpose   |
| -------- | ----- | --------- |
| TCP      | 22    | SSH       |
| UDP      | 51820 | WireGuard |
| ICMP     | -     | Ping      |

## Install tools on your laptop

```bash
brew install talosctl kubectl helm cilium-cli
```
