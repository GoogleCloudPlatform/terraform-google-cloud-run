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

module "job" {
  source = "../../modules/job-exec"
  # [restore-marker]   version = "~> 0.16"

  project_id                    = var.project_id
  name                          = "job-sa-creation"
  location                      = "us-central1"
  image                         = "us-docker.pkg.dev/cloudrun/container/job"
  exec                          = true
  create_service_account        = true
  service_account_project_roles = ["roles/run.invoker"]

  cloud_run_deletion_protection = var.cloud_run_deletion_protection
}
