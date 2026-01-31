/**
 * Copyright 2025 Google LLC
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

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = "ci-cloud-run-v2-sa"
  display_name = "Service account for ci-cloud-run-v2"
}

module "cloud_run_v2_gpu" {
  source = "GoogleCloudPlatform/cloud-run/google//modules/v2"

  service_name           = "ci-cloud-run-v2-gpu"
  project_id             = var.project_id
  location               = "us-central1"
  create_service_account = false
  service_account        = google_service_account.sa.email

  cloud_run_deletion_protection = var.cloud_run_deletion_protection

  containers = [{
    container_image = "us-docker.pkg.dev/cloudrun/container/hello"
    resources = {
      limits = {
        cpu        = "4"
        memory     = "16Gi"
        nvidia_gpu = "1"
      }
      cpu_idle = false
    }
  }]
  node_selector = {
    "accelerator" = "nvidia-l4"
  }
  gpu_zonal_redundancy_disabled = false
}
