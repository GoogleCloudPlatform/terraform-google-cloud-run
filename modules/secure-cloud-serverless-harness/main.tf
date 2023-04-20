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
  api = var.serverless_type == "CLOUD_RUN" ? "run" : "cloudfunctions"
  serverless_apis = [
    "vpcaccess.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "${local.api}.googleapis.com",
    "cloudkms.googleapis.com",
    "dns.googleapis.com"
  ]
  kms_apis = [
    "cloudkms.googleapis.com",
    "artifactregistry.googleapis.com"
  ]

  decrypters = join(",", concat(["serviceAccount:${google_project_service_identity.artifact_sa.email}"], var.decrypters))
  encrypters = join(",", concat(["serviceAccount:${google_project_service_identity.artifact_sa.email}"], var.encrypters))

}

resource "google_folder" "fld_serverless" {
  display_name = var.serverless_folder_suffix == "" ? "fldr-serverless" : "fldr-serverless-${var.serverless_folder_suffix}"
  parent       = var.parent_folder_id == "" ? "organizations/${var.org_id}" : "folders/${var.parent_folder_id}"
}

module "security_project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 13.0"
  random_project_id = "true"
  activate_apis     = local.kms_apis
  name              = var.security_project_name
  org_id            = var.org_id
  billing_account   = var.billing_account
  folder_id         = google_folder.fld_serverless.name
}

module "serverless_project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 13.0"
  random_project_id = "true"
  activate_apis     = local.serverless_apis
  name              = var.serverless_project_name
  org_id            = var.org_id
  billing_account   = var.billing_account
  folder_id         = google_folder.fld_serverless.name
}

module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 3.0"
  project_id = module.serverless_project.project_id
  prefix     = "sa"
  names      = ["serverless-${local.api}"]

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "google_project_iam_member" "cloud_run_sa_roles" {
  for_each = toset(var.service_account_project_roles)
  project  = module.serverless_project.project_id
  role     = each.value
  member   = module.service_accounts.iam_email

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "google_project_service_identity" "serverless_sa" {
  provider = google-beta

  project = module.serverless_project.project_id
  service = "${local.api}.googleapis.com"

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "google_service_account_iam_member" "identity_service_account_user" {
  service_account_id = module.service_accounts.service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_project_service_identity.serverless_sa.email}"

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "google_project_service_identity" "artifact_sa" {
  provider = google-beta

  project = module.security_project.project_id
  service = "artifactregistry.googleapis.com"

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "google_artifact_registry_repository" "repo" {
  project       = module.security_project.project_id
  location      = var.location
  repository_id = var.artifact_registry_repository_name
  description   = var.artifact_registry_repository_description
  format        = var.artifact_registry_repository_format
  kms_key_name  = module.artifact_registry_kms.keys[var.key_name]

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

resource "google_artifact_registry_repository_iam_member" "member" {
  project    = module.security_project.project_id
  location   = var.location
  repository = google_artifact_registry_repository.repo.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_project_service_identity.serverless_sa.email}"

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

module "artifact_registry_kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.2"

  project_id           = module.security_project.project_id
  location             = var.location
  keyring              = var.keyring_name
  keys                 = [var.key_name]
  set_decrypters_for   = [var.key_name]
  set_encrypters_for   = [var.key_name]
  decrypters           = [local.decrypters]
  encrypters           = [local.encrypters]
  set_owners_for       = length(var.owners) > 0 ? [var.key_name] : []
  owners               = [join(",", var.owners)]
  prevent_destroy      = var.prevent_destroy
  key_rotation_period  = var.key_rotation_period
  key_protection_level = var.key_protection_level

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}
