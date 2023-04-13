resource "kubernetes_namespace" "datadog" {
  count = var.datadog_api_key != null && var.datadog_app_key != null ? 1 : 0

  metadata {
    name = "datadog"
  }
}

resource "helm_release" "datadog" {
  count = var.datadog_api_key != null && var.datadog_app_key != null ? 1 : 0

  name      = "datadog"
  namespace = kubernetes_namespace.datadog[0].metadata[0].name

  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = "3.22.0"

  set_sensitive {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  set_sensitive {
    name  = "datadog.appKey"
    value = var.datadog_app_key
  }

  values = [<<YAML
datadog:
  site: ${var.datadog_site}
  # criSocketPath: /run/dockershim.sock
  clusterName: ${var.cluster_name}
  kubeStateMetricsCore:
    enabled: true
    labelsAsTags:
      node:
        topology_kubernetes_io_zone: kube_az
  nodeLabelsAsTags:
    topology.kubernetes.io/zone: kube_az
  logs:
    enabled: true
    containerCollectAll: true
  apm:
    enabled: ${var.datadog_apm}
    portEnabled: true
  dogstatsd:
    useHostPort: true
  processAgent:
    enabled: true
    processCollection: true
  serviceMonitoring:
    enabled: ${var.datadog_service_monitoring}
  systemProbe:
    enableOOMKill: true
  tags:
    - 'project:${var.project}'
  env:
    - name: DD_AUTOCONFIG_INCLUDE_FEATURES
      value: 'containerd'
    - name: DD_APM_IGNORE_RESOURCES
      value: 'GET /-/health-checks/(liveness|readiness),/-/health-checks/(liveness|readiness),GET /rb/startup'
agents:
  nodeSelector:
    ${var.datadog_agent_node_selector == null ? "{}" : indent(4, yamlencode(var.datadog_agent_node_selector))}
clusterAgent:
  nodeSelector:
    ${var.datadog_agent_node_selector == null ? "{}" : indent(4, yamlencode(var.datadog_agent_node_selector))}
YAML
  ]

  timeout = 900
}
