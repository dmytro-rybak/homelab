resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Cloudflare API token consumed by cert-manager DNS-01 solver and (separately)
# by external-dns. Two copies — one per namespace — since Kubernetes Secrets
# are namespace-scoped.
resource "kubernetes_secret" "cloudflare_api_token_cert_manager" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    api-token = var.cloudflare_api_token
  }
  type = "Opaque"
}

resource "helm_release" "cert_manager" {
  # Cilium must be running before cert-manager pods can schedule (CNI required
  # for Pod IPs).
  depends_on = [helm_release.cilium]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  values = [yamlencode({
    crds = {
      enabled = true
    }
    prometheus = {
      enabled = false
    }
  })]
}

# DNS-01 only — no HTTP-01 since the cluster API is not publicly exposed.
resource "kubectl_manifest" "cluster_issuer_staging" {
  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.cloudflare_api_token_cert_manager,
  ]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "letsencrypt-staging" }
    spec = {
      acme = {
        server              = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email               = var.acme_email
        privateKeySecretRef = { name = "letsencrypt-staging-account-key" }
        solvers = [{
          dns01 = {
            cloudflare = {
              apiTokenSecretRef = {
                name = kubernetes_secret.cloudflare_api_token_cert_manager.metadata[0].name
                key  = "api-token"
              }
            }
          }
        }]
      }
    }
  })
}

resource "kubectl_manifest" "cluster_issuer_prod" {
  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.cloudflare_api_token_cert_manager,
  ]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "letsencrypt-prod" }
    spec = {
      acme = {
        server              = "https://acme-v02.api.letsencrypt.org/directory"
        email               = var.acme_email
        privateKeySecretRef = { name = "letsencrypt-prod-account-key" }
        solvers = [{
          dns01 = {
            cloudflare = {
              apiTokenSecretRef = {
                name = kubernetes_secret.cloudflare_api_token_cert_manager.metadata[0].name
                key  = "api-token"
              }
            }
          }
        }]
      }
    }
  })
}

# Wildcard cert covering all subdomains under the internal subdomain.
# Issued via staging first; flip issuerRef to letsencrypt-prod when verified.
resource "kubectl_manifest" "wildcard_certificate" {
  depends_on = [kubectl_manifest.cluster_issuer_staging]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "homelab-wildcard"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "homelab-wildcard-tls"
      issuerRef = {
        name = "letsencrypt-staging"
        kind = "ClusterIssuer"
      }
      commonName = "*.${var.internal_subdomain}"
      dnsNames = [
        "*.${var.internal_subdomain}",
        var.internal_subdomain,
      ]
    }
  })
}
