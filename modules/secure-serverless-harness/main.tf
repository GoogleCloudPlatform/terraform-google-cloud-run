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
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "cloudkms.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
  kms_apis = concat([
    "cloudkms.googleapis.com",
    "artifactregistry.googleapis.com"
  ], var.security_project_extra_apis)

  network_apis = concat([
    "vpcaccess.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com"
  ], var.network_project_extra_apis)
  eventarc_identities = [for project in module.serverless_project : "serviceAccount:${project.services_identities["eventarc"]}"]
  gcs_identities      = [for project in module.serverless_project : "serviceAccount:${project.services_identities["gcs"]}"]
  decrypters          = join(",", concat(["serviceAccount:${google_project_service_identity.artifact_sa.email}"], local.eventarc_identities, local.gcs_identities, var.decrypters))
  encrypters          = join(",", concat(["serviceAccount:${google_project_service_identity.artifact_sa.email}"], local.eventarc_identities, local.gcs_identities, var.encrypters))

}

resource "google_folder" "fld_serverless" {
  display_name = var.serverless_folder_suffix == "" ? "fldr-serverless" : "fldr-serverless-${var.serverless_folder_suffix}"
  parent       = var.parent_folder_id == "" ? "organizations/${var.org_id}" : "folders/${var.parent_folder_id}"
}

module "network_project" {
  count             = var.use_shared_vpc ? 1 : 0
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 15.0"
  random_project_id = "true"
  activate_apis     = local.network_apis
  name              = var.network_project_name
  org_id            = var.org_id
  billing_account   = var.billing_account
  folder_id         = google_folder.fld_serverless.name

  disable_services_on_destroy = var.disable_services_on_destroy

  enable_shared_vpc_host_project = true
}

module "security_project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 15.0"
  random_project_id = "true"
  activate_apis     = local.kms_apis
  name              = var.security_project_name
  org_id            = var.org_id
  billing_account   = var.billing_account
  folder_id         = google_folder.fld_serverless.name

  disable_services_on_destroy = var.disable_services_on_destroy
}

module "serverless_project" {
  source = "../service-project-factory"

  for_each = toset(var.serverless_project_names)

  billing_account               = var.billing_account
  base_serverless_api           = var.base_serverless_api
  org_id                        = var.org_id
  activate_apis                 = concat(local.serverless_apis, try(var.serverless_project_extra_apis[each.value], []))
  folder_name                   = google_folder.fld_serverless.name
  project_name                  = each.value
  service_account_project_roles = try(var.service_account_project_roles[each.value], [])

  disable_services_on_destroy = var.disable_services_on_destroy
}


resource "google_artifact_registry_repository" "repo" {
  count         = var.base_serverless_api == "run.googleapis.com" ? 1 : 0
  project       = module.security_project.project_id
  location      = var.location
  repository_id = var.artifact_registry_repository_name
  description   = var.artifact_registry_repository_description
  format        = var.artifact_registry_repository_format
  kms_key_name  = module.artifact_registry_kms.keys[var.key_name]

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

resource "google_artifact_registry_repository_iam_member" "member" {
  for_each   = var.base_serverless_api == "run.googleapis.com" ? module.serverless_project : {}
  project    = module.security_project.project_id
  location   = var.location
  repository = google_artifact_registry_repository.repo[0].repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${each.value.cloud_serverless_service_identity_email}"

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

module "artifact_registry_kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 3.0"

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
    time_sleep.wait_vpc_sc_propagation
  ]
}

resource "google_project_service_identity" "artifact_sa" {
  provider = google-beta

  project = module.security_project.project_id
  service = "artifactregistry.googleapis.com"

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}
