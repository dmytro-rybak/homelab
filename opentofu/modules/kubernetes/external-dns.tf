resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "cloudflare_api_token_external_dns" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }
  data = {
    cloudflare_api_token = var.cloudflare_api_token
  }
  type = "Opaque"
}

resource "helm_release" "external_dns" {
  depends_on = [helm_release.cilium]

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_version
  namespace  = kubernetes_namespace.external_dns.metadata[0].name

  values = [yamlencode({
    provider = {
      name = "cloudflare"
    }
    env = [{
      name = "CF_API_TOKEN"
      valueFrom = {
        secretKeyRef = {
          name = kubernetes_secret.cloudflare_api_token_external_dns.metadata[0].name
          key  = "cloudflare_api_token"
        }
      }
    }]
    domainFilters = [var.internal_subdomain]
    sources = [
      "service",
      "gateway-httproute",
    ]
    policy     = "sync"
    txtOwnerId = "homelab"
    extraArgs = [
      # Records target private IPs only reachable via WireGuard. Don't proxy
      # through Cloudflare; resolve directly so kubectl/clients via WG work.
      "--cloudflare-proxied=false",
    ]
  })]
}
