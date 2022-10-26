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

module "serverless_project_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 13.0"

  project_id                  = var.serverless_project_id
  disable_services_on_destroy = false

  activate_apis = [
    "vpcaccess.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "run.googleapis.com"
  ]
}

module "vpc_project_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 13.0"

  project_id                  = var.vpc_project_id
  disable_services_on_destroy = false

  activate_apis = [
    "vpcaccess.googleapis.com",
    "compute.googleapis.com"
  ]
}

module "kms_project_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 13.0"

  project_id                  = var.kms_project_id
  disable_services_on_destroy = false

  activate_apis = [
    "cloudkms.googleapis.com"
  ]
}

module "cloud_run_network" {
  source = "../secure-cloud-run-net"

  connector_name            = var.connector_name
  subnet_name               = var.subnet_name
  location                  = var.location
  vpc_project_id            = var.vpc_project_id
  serverless_project_id     = var.serverless_project_id
  shared_vpc_name           = var.shared_vpc_name
  connector_on_host_project = false
  ip_cidr_range             = var.ip_cidr_range
  create_subnet             = var.create_subnet
  resource_names_suffix     = var.resource_names_suffix

  depends_on = [
    module.vpc_project_apis
  ]
}

resource "google_project_service_identity" "serverless_sa" {
  provider = google-beta

  project = var.serverless_project_id
  service = "run.googleapis.com"
}

data "google_service_account" "cloud_run_sa" {
  account_id = var.cloud_run_sa
}

resource "google_service_account_iam_member" "identity_service_account_user" {
  service_account_id = data.google_service_account.cloud_run_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_project_service_identity.serverless_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_iam" {
  count = var.grant_artifact_register_reader ? 1 : 0

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
  policy_for            = var.policy_for
  folder_id             = var.folder_id
  organization_id       = var.organization_id

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
  domain           = var.domain
  env_vars         = var.env_vars
  members          = var.members
  region           = var.region

  depends_on = [
    module.serverless_project_apis,
    google_artifact_registry_repository_iam_member.artifact_registry_iam,
    google_service_account_iam_member.identity_service_account_user
  ]
}
