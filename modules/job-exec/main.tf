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

resource "google_cloud_run_v2_job" "job" {
  name         = var.name
  project      = var.project_id
  location     = var.location
  launch_stage = var.launch_stage
  template {
    labels = var.labels
    template {
      max_retries = var.max_retries
      containers {
        image   = var.image
        command = var.container_command
        args    = var.argument

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
          cloud_sql_instance {
            instances = volumes.value.cloud_sql_instance["instances"]
          }
        }
      }

      dynamic "vpc_access" {
        for_each = var.vpc_access
        content {
          connector = vpc_access.value["connector"]
          egress    = vpc_access.value["egress"]
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
