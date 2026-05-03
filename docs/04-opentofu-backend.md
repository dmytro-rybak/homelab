# 04 - OpenTofu Backend

State is stored in Hetzner Object Storage using the S3 backend.

## Create the Bucket

In Hetzner Cloud Console → Object Storage → Create Bucket:

- Region: `fsn1`
- Name: globally unique
- Enable **Object Lock**

## Generate S3 Credentials

In Hetzner Cloud Console → Object Storage → S3 Credentials → Generate:

- Description: `homelab`

Add to `~/.aws/credentials`:

```ini
[homelab]
aws_access_key_id     = <access_key>
aws_secret_access_key = <secret_key>
```

## Configure Backend

Copy the example and fill in your values:

```bash
cp backend.hcl.example backend.hcl
```

## Initialize

```bash
tofu init -backend-config=backend.hcl
```

State file is created in the bucket on first `tofu apply`.
