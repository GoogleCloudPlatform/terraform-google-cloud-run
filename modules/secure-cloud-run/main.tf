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
  serverless_apis = [
    "vpcaccess.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "run.googleapis.com",
    "cloudkms.googleapis.com"
  ]
  vpc_apis = [
    "vpcaccess.googleapis.com",
    "compute.googleapis.com"
  ]
}

resource "google_project_service" "serverless_project_apis" {
  for_each = toset(local.serverless_apis)

  project            = var.serverless_project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_project_service" "vpc_project_apis" {
  for_each = toset(local.vpc_apis)

  project            = var.vpc_project_id
  service            = each.value
  disable_on_destroy = false
}


module "cloud_run_network" {
  source = "../secure-cloud-run-net"

  connector_name            = var.connector_name
  subnet_name               = var.subnet_name
  location                  = var.location
  vpc_project_id            = var.vpc_project_id
  serverless_project_id     = var.serverless_project_id
  shared_vpc_name           = var.shared_vpc_name
  connector_on_host_project = true
  ip_cidr_range             = var.ip_cidr_range

  depends_on = [
    google_project_service.vpc_project_apis
  ]
}

resource "google_project_service_identity" "serverless_sa" {
  provider = google-beta

  project = var.serverless_project_id
  service = "run.googleapis.com"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_iam" {
  provider = google-beta
  count    = var.use_artifact_registry_image ? 0 : 1

  project    = var.artifact_registry_repository_project_id
  location   = var.artifact_registry_repository_location
  repository = var.artifact_registry_repository_name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_project_service_identity.serverless_sa.email}"
}

module "cloud_run_security" {
  source = "../secure-cloud-run-security"

  kms_project_id        = var.kms_project_id
  location              = var.location
  serverless_project_id = var.serverless_project_id
  prevent_destroy       = var.prevent_destroy
  key_name              = var.key_name
  keyring_name          = var.keyring_name
  key_rotation_period   = var.key_rotation_period
  key_protection_level  = var.key_protection_level

  encrypters = [
    "serviceAccount:${google_project_service_identity.serverless_sa.email}",
    "serviceAccount:${var.cloud_run_sa}"
  ]

  decrypters = [
    "serviceAccount:${google_project_service_identity.serverless_sa.email}",
    "serviceAccount:${var.cloud_run_sa}"
  ]
}

module "cloud_run_core" {
  source = "../secure-cloud-run-core"

  service_name     = var.service_name
  location         = var.location
  project_id       = var.serverless_project_id
  image            = var.image
  cloud_run_sa     = var.cloud_run_sa
  vpc_connector_id = module.cloud_run_network.connector_id
  encryption_key   = module.cloud_run_security.key_self_link
  env_vars         = var.env_vars
  members          = var.members
  region           = var.region

  depends_on = [
    google_project_service.serverless_project_apis,
    google_artifact_registry_repository_iam_member.artifact_registry_iam
  ]
}
