# 01 - Proxmox Setup

## System Upgrade

```bash
apt update && apt full-upgrade
```

## SSH Configuration

Disable SSH password, only key authentication is allowed

```bash
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

Set the root password

```bash
passwd
```

## Fix Locale

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

Force IPv4 preference so DNS resolution doesn't attempt IPv6 first (avoids ~2min timeouts in Proxmox tasks):

```bash
echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
systemctl restart pvedaemon pveproxy
```

## Automatic Security Updates

```bash
apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades
```
