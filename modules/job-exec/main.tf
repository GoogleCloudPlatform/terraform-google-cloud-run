/**
 * Copyright 2023 Google LLC
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

data "google_compute_default_service_account" "default" {
  count   = !var.create_service_account && var.service_account_email == "" ? 1 : 0
  project = var.project_id
}

locals {
  service_account = (
    var.service_account_email != ""
    ? var.service_account_email
    : (
      var.create_service_account
      ? google_service_account.sa[0].email
      : data.google_compute_default_service_account.default[0].email
    )
  )

  create_service_account = var.create_service_account ? var.service_account_email == "" : false

  service_account_prefix = substr(var.name, 0, 27)
  service_account_output = local.create_service_account ? {
    id     = google_service_account.sa[0].account_id,
    email  = google_service_account.sa[0].email,
    member = google_service_account.sa[0].member
    } : (var.service_account_email != "" ? {
      id     = split("@", var.service_account_email)[0],
      email  = var.service_account_email,
      member = "serviceAccount:${var.service_account_email}"
      } : {
      id     = data.google_compute_default_service_account.default[0].name,
      email  = data.google_compute_default_service_account.default[0].email,
      member = data.google_compute_default_service_account.default[0].member
  })

  service_account_project_roles = local.create_service_account ? var.service_account_project_roles : []
}

resource "google_service_account" "sa" {
  count        = local.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = "${local.service_account_prefix}-sa"
  display_name = "Service account for ${var.name} in ${var.location}"
}

resource "google_project_iam_member" "roles" {
  for_each = toset(local.service_account_project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${local.service_account}"
}

resource "google_cloud_run_v2_job" "job" {
  name         = var.name
  project      = var.project_id
  location     = var.location
  launch_stage = var.launch_stage
  labels       = var.labels

  deletion_protection = var.cloud_run_deletion_protection

  template {
    labels      = var.labels
    parallelism = var.parallelism
    task_count  = var.task_count

    template {
      max_retries     = var.max_retries
      service_account = local.service_account
      timeout         = var.timeout

      containers {
        image   = var.image
        command = var.container_command
        args    = var.argument

        resources {
          limits = var.limits
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
            dynamic "value_source" {
              for_each = env.value.value_source
              content {
                secret_key_ref {
                  secret  = value_source.value.secret_key_ref["secret"]
                  version = value_source.value.secret_key_ref["version"]
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
      }

      dynamic "volumes" {
        for_each = var.volumes
        content {
          name = volumes.value["name"]

          dynamic "cloud_sql_instance" {
            for_each = volumes.value.cloud_sql_instance != null && try(volumes.value.cloud_sql_instance.instances, null) != null ? [volumes.value.cloud_sql_instance.instances] : []
            content {
              instances = try(volumes.value.cloud_sql_instance.instances, [])
            }
          }

          dynamic "gcs" {
            for_each = volumes.value.gcs != null && try(volumes.value.gcs.bucket, null) != null ? [volumes.value.gcs.bucket] : []
            content {
              bucket    = volumes.value.gcs.bucket
              read_only = volumes.value.gcs.read_only
            }
          }
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
    }
  }
}

data "google_client_config" "default" {}

resource "terracurl_request" "exec" {
  count  = var.exec ? 1 : 0
  name   = "exec-job"
  url    = "https://run.googleapis.com/v2/${google_cloud_run_v2_job.job.id}:run"
  method = "POST"
  headers = {
    Authorization = "Bearer ${data.google_client_config.default.access_token}"
    Content-Type  = "application/json",
  }
  response_codes = [200]
  // no-op destroy
  // we don't use terracurl_request data source as that will result in
  // repeated job runs on every refresh
  destroy_url            = "https://run.googleapis.com/v2/${google_cloud_run_v2_job.job.id}"
  destroy_method         = "GET"
  destroy_response_codes = [200]
  destroy_headers = {
    Authorization = "Bearer ${data.google_client_config.default.access_token}"
    Content-Type  = "application/json",
  }
}
