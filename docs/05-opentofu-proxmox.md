# 05 - OpenTofu Proxmox Provider

## Generate an API Token

In Proxmox UI → Datacenter → Permissions → API Tokens → Add:

- User: `root@pam`
- Token ID: `tofu`
- Description: `OpenTofu`
- Privilege Separation: unchecked (inherit full user permissions)

Save the secret — it's only shown once.

## Use the Token

Export it in your shell (single quotes — `!` triggers zsh history expansion):

```bash
export PROXMOX_VE_API_TOKEN='root@pam!tofu=<YOUR_API_TOKEN>'
```

Then run any tofu command:

```bash
tofu plan
```

The provider reads `PROXMOX_VE_API_TOKEN` automatically.
