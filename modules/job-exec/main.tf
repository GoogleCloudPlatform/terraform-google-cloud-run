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
  launch_stage = "BETA"
  template {
    template {
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
          for_each = var.cr_env_secret_vars
          content {
            name = env.value["name"]
            dynamic "value_source" {
              for_each = env.value.value_source
              content {
                secret_key_ref  {
                  secret = value_source.value.secret_key_ref["secret"]
		  version = value_source.value.secret_key_ref["version"]
                }
              }
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
