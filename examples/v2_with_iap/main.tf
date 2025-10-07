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

module "cloud_run_v2" {
  source = "../../modules/v2"
  # [restore-marker]   version = "~> 0.16"

  service_name = "ci-cloud-run-v2-iap"
  project_id   = var.project_id
  location     = "us-central1"
  containers = [
    {
      container_image = "us-docker.pkg.dev/cloudrun/container/hello"
      container_name  = "hello-world"
    }
  ]

  launch_stage                  = "BETA"
  iap_members                   = ["user:test@test.test"]
  cloud_run_deletion_protection = false
}
