/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cmek_template_annotation = var.encryption_key != null ? { "run.googleapis.com/encryption-key" = var.encryption_key } : {}
  template_annotations     = merge(var.template_annotations, local.cmek_template_annotation)
}

resource "google_cloud_run_service" "main" {
  provider                   = google-beta
  name                       = var.service_name
  location                   = var.location
  project                    = var.project_id
  autogenerate_revision_name = var.generate_revision_name

  metadata {
    labels      = var.service_labels
    annotations = var.service_annotations
  }

  template {
    spec {
      containers {
        image   = var.image
        command = var.container_command
        args    = var.argument

        ports {
          name           = var.ports["name"]
          container_port = var.ports["port"]
        }

        resources {
          limits   = var.limits
          requests = var.requests
        }

        startup_probe {
          dynamic "http_get" {
            for_each = var.startup_probe["http_get"] != null ? [var.startup_probe["http_get"]] : []
            content {
              path = var.startup_probe["http_get"]["path"]
            }
          }

          dynamic "tcp_socket" {
            for_each = var.startup_probe["tcp_socket"] != null ? [var.startup_probe["tcp_socket"]] : []
            content {
              port = var.startup_probe["tcp_socket"]["port"]
            }
          }

          initial_delay_seconds = var.startup_probe["initial_delay_seconds"]
          period_seconds        = var.startup_probe["period_seconds"]
          timeout_seconds       = var.startup_probe["timeout_seconds"]
          failure_threshold     = var.startup_probe["failure_threshold"]
        }

        liveness_probe {
          dynamic "http_get" {
            for_each = var.liveness_probe["http_get"] != null ? [var.liveness_probe["http_get"]] : []
            content {
              path = var.liveness_probe["http_get"]["path"]
            }
          }
          initial_delay_seconds = var.liveness_probe["initial_delay_seconds"]
          period_seconds        = var.liveness_probe["period_seconds"]
          timeout_seconds       = var.liveness_probe["timeout_seconds"]
          failure_threshold     = var.liveness_probe["failure_threshold"]
        }

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.value["name"]
            value = env.value["value"]
          }
        }

        dynamic "env" {
          for_each = var.env_secret_vars
          content {
            name = env.value["name"]
            dynamic "value_from" {
              for_each = env.value.value_from
              content {
                secret_key_ref {
                  name = value_from.value.secret_key_ref["name"]
                  key  = value_from.value.secret_key_ref["key"]
                }
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = var.volume_mounts
          content {
            name       = volume_mounts.value["name"]
            mount_path = volume_mounts.value["mount_path"]
          }
        }
      }                                                 // container
      container_concurrency = var.container_concurrency # maximum allowed concurrent requests 0,1,2-N
      timeout_seconds       = var.timeout_seconds       # max time instance is allowed to respond to a request
      service_account_name  = var.service_account_email

      dynamic "volumes" {
        for_each = var.volumes
        content {
          name = volumes.value["name"]
          dynamic "secret" {
            for_each = volumes.value.secret
            content {
              secret_name = secret.value["secret_name"]
              items {
                key  = secret.value.items["key"]
                path = secret.value.items["path"]
              }
            }
          }
        }
      }

    } // spec
    metadata {
      labels      = var.template_labels
      annotations = local.template_annotations
      name        = var.generate_revision_name ? null : "${var.service_name}-${var.traffic_split.0.revision_name}"
    } // metadata
  }   // template

  # User can generate multiple scenarios here
  # Providing 50-50 split with revision names
  # latest_revision is true only when revision_name is not provided, else its false
  dynamic "traffic" {
    for_each = var.traffic_split
    content {
      percent         = lookup(traffic.value, "percent", 100)
      latest_revision = lookup(traffic.value, "latest_revision", null)
      revision_name   = lookup(traffic.value, "latest_revision") ? null : lookup(traffic.value, "revision_name")
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].labels["commit-sha"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      metadata[0].labels["commit-sha"],
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"],
      metadata[0].annotations["client.knative.dev/user-image"],
      traffic
    ]
  }
}

resource "google_cloud_run_domain_mapping" "domain_map" {
  for_each = toset(var.verified_domain_name)
  provider = google-beta
  location = google_cloud_run_service.main.location
  name     = each.value
  project  = google_cloud_run_service.main.project

  metadata {
    labels      = var.domain_map_labels
    annotations = var.domain_map_annotations
    namespace   = var.project_id
  }

  spec {
    route_name       = google_cloud_run_service.main.name
    force_override   = var.force_override
    certificate_mode = var.certificate_mode
  }
}

resource "google_cloud_run_service_iam_member" "authorize" {
  count    = length(var.members)
  location = google_cloud_run_service.main.location
  project  = google_cloud_run_service.main.project
  service  = google_cloud_run_service.main.name
  role     = "roles/run.invoker"
  member   = var.members[count.index]
}
