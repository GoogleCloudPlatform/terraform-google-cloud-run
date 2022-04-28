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

resource "google_kms_key_ring" "keyring" {
  name     = "key-ring-example"
  location = "us-central1"
  project  = var.project_id
}

resource "google_kms_crypto_key" "example_key" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.example_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}

module "cloud_run" {
  source = "../../"

  service_name = "ci-cloud-run"
  project_id   = var.project_id
  location     = "us-central1"
  image        = "us-docker.pkg.dev/cloudrun/container/hello"

  encryption_key = google_kms_crypto_key.example_key.id

  depends_on = [
    google_kms_crypto_key_iam_member.crypto_key
  ]
}
