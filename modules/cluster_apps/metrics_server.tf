resource "helm_release" "metrics_server" {
  name      = "metrics-server"
  namespace = kubernetes_namespace.cluster_apps.metadata[0].name

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.8.4"
}
