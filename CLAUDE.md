# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal homelab infrastructure built on **Proxmox** (hosted on Hetzner Cloud), accessed via **WireGuard VPN**, with **Kubernetes** planned via Talos. Infrastructure-as-Code uses **OpenTofu**.

## Required Tools (macOS)

```bash
brew install talosctl kubectl helm cilium-cli opentofu
```

## Network Architecture

- **Hypervisor**: Proxmox on Hetzner Cloud server
- **VPN**: WireGuard on UDP 51820; VPN subnet `10.25.0.0/24`
  - Server: `10.25.0.1` (Proxmox host)
  - Client: `10.25.0.2` (MacBook)
- **SSH access**: `ssh homelab` (via WireGuard tunnel, see `~/.ssh/config`)
- **Hetzner firewall**: Blocks everything except WireGuard (UDP 51820) and ICMP by default

## Repository Structure

```
opentofu/
  infrastructure/   # OpenTofu root modules (environment-specific)
  modules/          # Reusable OpenTofu modules
docs/               # Documentation
```

## Infrastructure-as-Code (OpenTofu)

OpenTofu is the IaC tool (open-source Terraform fork). State files, tfvars, and `.terraform/` directories are gitignored — never commit these. The `opentofu/` directory is the canonical location for all IaC code.

## Security Notes

- SSH password auth is disabled on Proxmox; key-only
- WireGuard private/public keys and `wg*.conf` files are gitignored — never commit them
- Kubeconfig and all credential files (`.pem`, `.key`, `.crt`, `.env`) are gitignored
