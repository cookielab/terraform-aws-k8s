resource "kubernetes_daemonset" "instance_metadata_exporter" {
  count = var.datadog_api_key != null && var.datadog_app_key != null ? 1 : 0

  metadata {
    name      = "aws-instance-metadata-exporter"
    namespace = "cluster-apps"
    labels = {
      "app.kubernetes.io/component" = "exporter"
      "app.kubernetes.io/name"      = "aws-instance-metadata-exporter"
    }
    annotations = {
      "ad.datadoghq.com/aws-instance-metadata-exporter.check_names"  = "[\"openmetrics\"]",
      "ad.datadoghq.com/aws-instance-metadata-exporter.init_configs" = "[{}]",
      "ad.datadoghq.com/aws-instance-metadata-exporter.instances"    = <<-INSTANCES
        [
          {
            "openmetrics_endpoint": "http://%%host%%:%%port%%/metrics",
            "namespace": "${var.project}",
            "metrics": [
              "aws_instance_spot_metadata_service_available",
              "aws_instance_spot_termination_imminent",
              "aws_instance_spot_termination_in",
              "aws_instance_scheduled_metadata_service_available",
              "aws_instance_scheduled_action_iminent",
              "aws_instance_scheduled_action_start_in",
              "aws_instance_scheduled_action_end_in"
            ]
          }
        ]
        INSTANCES
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name"      = "aws-instance-metadata-exporter"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name"      = "aws-instance-metadata-exporter"
        }
        annotations = {
          "ad.datadoghq.com/aws-instance-metadata-exporter.check_names"  = "[\"openmetrics\"]",
          "ad.datadoghq.com/aws-instance-metadata-exporter.init_configs" = "[{}]",
          "ad.datadoghq.com/aws-instance-metadata-exporter.instances"    = <<-INSTANCES
            [
              {
                "openmetrics_endpoint": "http://%%host%%:%%port%%/metrics",
                "namespace": "${var.project}",
                "metrics": [
                  "aws_instance_spot_metadata_service_available",
                  "aws_instance_spot_termination_imminent",
                  "aws_instance_spot_termination_in",
                  "aws_instance_scheduled_metadata_service_available",
                  "aws_instance_scheduled_action_iminent",
                  "aws_instance_scheduled_action_start_in",
                  "aws_instance_scheduled_action_end_in"
                ]
              }
            ]
          INSTANCES
        }
      }

      spec {
        container {
          image = "public.ecr.aws/cookielab/aws-instance-metadata-exporter:main"
          name  = "aws-instance-metadata-exporter"

          port {
            container_port = 9189
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9189
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
