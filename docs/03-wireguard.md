# 03 - WireGuard VPN

## Generate Server Keys

```bash
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
chmod 600 /etc/wireguard/privatekey
```

## Configure WireGuard

Edit the WireGuard config

```bash
nano /etc/wireguard/wg0.conf
```

Server (`10.25.0.1`):

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

MacBook (`10.25.0.2`):

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

## Start the Tunnel

```bash
wg-quick up wg0
# or
wg-quick down wg0 && wg-quick up wg0
```

## Hetzner Firewall

Lock down the Hetzner firewall — only allow:

| Protocol | Port  | Purpose   |
| -------- | ----- | --------- |
| UDP      | 51820 | WireGuard |
| ICMP     | -     | Ping      |

Open SSH temporarily if you need to recover from a broken VPN config:

| Protocol | Port  | Purpose   |
| -------- | ----- | --------- |
| TCP      | 22    | SSH       |
| UDP      | 51820 | WireGuard |
| ICMP     | -     | Ping      |
