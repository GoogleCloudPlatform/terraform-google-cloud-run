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

module "serverless_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 15.0"
  random_project_id           = "true"
  activate_apis               = var.activate_apis
  name                        = var.project_name
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.folder_name
  disable_services_on_destroy = var.disable_services_on_destroy

  svpc_host_project_id = var.network_project_id
  grant_network_role   = var.network_project_id != "" ? true : false
}

module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.2"
  project_id = module.serverless_project.project_id
  prefix     = "sa"
  names      = var.base_serverless_api == "run.googleapis.com" ? ["cloud-run"] : ["cloud-function"]

  depends_on = [
    module.serverless_project
  ]
}

resource "google_project_iam_member" "cloud_run_sa_roles" {
  for_each = toset(var.service_account_project_roles)
  project  = module.serverless_project.project_id
  role     = each.value
  member   = module.service_accounts.iam_email
}

resource "google_project_service_identity" "serverless_sa" {
  provider = google-beta

  project = module.serverless_project.project_id
  service = var.base_serverless_api
}

resource "google_service_account_iam_member" "identity_service_account_user" {
  service_account_id = module.service_accounts.service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_project_service_identity.serverless_sa.email}"
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta

  project = module.serverless_project.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service_identity" "eventarc_sa" {
  provider = google-beta

  project = module.serverless_project.project_id
  service = "eventarc.googleapis.com"
}

data "google_storage_project_service_account" "gcs_account" {
  project = module.serverless_project.project_id
}

resource "google_project_iam_member" "gcs_pubsub_publishing" {
  count   = var.base_serverless_api == "run.googleapis.com" ? 0 : 1
  project = module.serverless_project.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_project_iam_member" "eventarc_service_agent" {
  project = module.serverless_project.project_id
  role    = "roles/eventarc.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.eventarc_sa.email}"
}
