/**
 * Copyright 2022 Google LLC
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
  key_name = "crypto-key-example"
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.1"

  project_id         = var.project_id
  location           = "us-central1"
  keyring            = "key-ring-example"
  keys               = [local.key_name]
  set_decrypters_for = [local.key_name]
  set_encrypters_for = [local.key_name]
  decrypters = [
    "serviceAccount:${google_project_service_identity.serverless_sa.email}",
  ]
  encrypters = [
    "serviceAccount:${google_project_service_identity.serverless_sa.email}",
  ]
  prevent_destroy = false
}

resource "google_project_service_identity" "serverless_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "run.googleapis.com"
}

module "cloud_run" {
  source = "../../"

  service_name = "ci-cloud-run"
  project_id   = var.project_id
  location     = "us-central1"
  image        = "us-docker.pkg.dev/cloudrun/container/hello"

  encryption_key = module.kms.keys[local.key_name]
}
