/**
 * Copyright 2024 Google LLC
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

resource "google_cloud_run_v2_service" "main" {
  provider = google-beta

  project     = var.project_id
  name        = var.service_name
  location    = var.location
  description = var.description
  labels      = var.service_labels

  template {
    revision        = var.revision
    labels          = var.template_labels
    annotations     = var.template_annotations
    timeout         = var.timeout
    service_account = var.service_account

    execution_environment            = var.execution_environment
    encryption_key                   = var.encryption_key
    max_instance_request_concurrency = var.max_instance_request_concurrency
    session_affinity                 = var.session_affinity

    dynamic "scaling" {
      for_each = var.template_scaling[*]
      content {
        min_instance_count = scaling.value.min_instance_count
        max_instance_count = scaling.value.max_instance_count
      }
    }

    dynamic "vpc_access" {
      for_each = var.vpc_access[*]
      content {
        connector = vpc_access.value.connector
        egress    = vpc_access.value.egress
        dynamic "network_interfaces" {
          for_each = vpc_access.value.network_interfaces[*]
          content {
            network    = network_interfaces.value.network
            subnetwork = network_interfaces.value.subnetwork
            tags       = network_interfaces.value.tags
          }
        }
      }
    }

    dynamic "containers" {
      for_each = var.containers
      content {
        name        = containers.value.container_name
        image       = containers.value.container_image
        command     = containers.value.container_command
        args        = containers.value.container_args
        working_dir = containers.value.working_dir
        depends_on  = containers.value.depends_on_container

        ports {
          name           = containers.value.ports["name"]
          container_port = containers.value.ports["container_port"]
        }

        resources {
          limits            = containers.value.resources.limits
          cpu_idle          = containers.value.resources.cpu_idle
          startup_cpu_boost = containers.value.resources.startup_cpu_boost
        }

        dynamic "startup_probe" {
          for_each = containers.value.startup_probe[*]
          content {
            failure_threshold     = startup_probe.value.failure_threshold
            initial_delay_seconds = startup_probe.value.initial_delay_seconds
            timeout_seconds       = startup_probe.value.timeout_seconds
            period_seconds        = startup_probe.value.period_seconds

            dynamic "http_get" {
              for_each = startup_probe.value.http_get[*]
              content {
                path = http_get.value.path
                port = http_get.value.port

                dynamic "http_headers" {
                  for_each = http_get.value.http_headers[*]
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value.tcp_socket[*]
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value.grpc[*]
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }

        dynamic "liveness_probe" {
          for_each = containers.value.liveness_probe[*]
          content {
            failure_threshold     = liveness_probe.value.failure_threshold
            initial_delay_seconds = liveness_probe.value.initial_delay_seconds
            timeout_seconds       = liveness_probe.value.timeout_seconds
            period_seconds        = liveness_probe.value.period_seconds

            dynamic "http_get" {
              for_each = liveness_probe.value.http_get[*]
              content {
                path = http_get.value.path
                port = http_get.value.port

                dynamic "http_headers" {
                  for_each = http_get.value.http_headers[*]
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = liveness_probe.value.tcp_socket[*]
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = liveness_probe.value.grpc[*]
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }

        dynamic "env" {
          for_each = containers.value.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = containers.value.env_secret_vars
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value.secret
                version = env.value.version
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = containers.value.volume_mounts
          content {
            name       = volume_mounts.value["name"]
            mount_path = volume_mounts.value["mount_path"]
          }
        }
      }
    } // containers

    dynamic "volumes" {
      for_each = var.volumes
      content {
        name = volumes.value["name"]

        dynamic "secret" {
          for_each = volumes.value.secret[*]
          content {
            secret = secret.value["secret"]
            items {
              path    = secret.value.items["path"]
              version = secret.value.items["version"]
              mode    = secret.value.items["mode"]
            }
          }
        }

        dynamic "cloud_sql_instance" {
          for_each = volumes.value.cloud_sql_instance[*]
          content {
            instances = cloud_sql_instance.value["instances"]
          }
        }
        dynamic "empty_dir" {
          for_each = volumes.value.empty_dir[*]
          content {
            medium     = empty_dir.value["medium"]
            size_limit = empty_dir.value["size_limit"]
          }
        }
        dynamic "gcs" {
          for_each = volumes.value.gcs[*]
          content {
            bucket    = gcs.value["bucket"]
            read_only = gcs.value["read_only"]
          }
        }
        dynamic "nfs" {
          for_each = volumes.value.nfs[*]
          content {
            server    = nfs.value["server"]
            path      = nfs.value["path"]
            read_only = nfs.value["read_only"]
          }
        }
      }
    }
  } // template

  annotations      = var.service_annotations
  client           = var.client.name
  client_version   = var.client.version
  ingress          = var.ingress
  launch_stage     = var.launch_stage
  custom_audiences = var.custom_audiences

  dynamic "binary_authorization" {
    for_each = var.binary_authorization[*]
    content {
      breakglass_justification = binary_authorization.value.breakglass_justification
      use_default              = binary_authorization.value.use_default
    }
  }

  dynamic "scaling" {
    for_each = var.service_scaling[*]
    content {
      min_instance_count = scaling.value.min_instance_count
    }
  }

  dynamic "traffic" {
    for_each = var.traffic
    content {
      percent  = traffic.value.percent
      type     = traffic.value.type
      revision = traffic.value.revision
      tag      = traffic.value.tag
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "authorize" {
  for_each = toset(var.members)
  location = google_cloud_run_v2_service.main.location
  project  = google_cloud_run_v2_service.main.project
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  member   = each.value
}
