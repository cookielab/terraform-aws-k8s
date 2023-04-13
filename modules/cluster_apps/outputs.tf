output "kube_namespace" {
  value = kubernetes_namespace.cluster_apps.metadata[0].name
}
