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

data "google_project" "serverless_project_id" {
  project_id = var.serverless_project_id
}

resource "google_project_service_identity" "vpcaccess_identity_sa" {
  provider = google-beta

  project = var.serverless_project_id
  service = "vpcaccess.googleapis.com"
}

# By default, roles/compute.networkUser is granted only on the connector subnet
# in the host project, following Shared VPC least-privilege guidance. The legacy
# project-level grant can be restored with grant_network_user_on_host_project = true.
locals {
  grant_subnet_network_user  = !var.connector_on_host_project && !var.grant_network_user_on_host_project
  grant_project_network_user = !var.connector_on_host_project && var.grant_network_user_on_host_project
}

resource "google_compute_subnetwork_iam_member" "gca_sa_vpcaccess_subnet" {
  count = local.grant_subnet_network_user ? 1 : 0

  project    = var.vpc_project_id
  region     = var.location
  subnetwork = local.subnet_name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_project_service_identity.vpcaccess_identity_sa.email}"

  depends_on = [google_compute_subnetwork.vpc_subnetwork]
}

resource "google_compute_subnetwork_iam_member" "cloud_services_subnet" {
  count = local.grant_subnet_network_user ? 1 : 0

  project    = var.vpc_project_id
  region     = var.location
  subnetwork = local.subnet_name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${data.google_project.serverless_project_id.number}@cloudservices.gserviceaccount.com"

  depends_on = [google_compute_subnetwork.vpc_subnetwork]
}

resource "google_project_iam_member" "gca_sa_vpcaccess" {
  count = local.grant_project_network_user ? 1 : 0

  project = var.vpc_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_project_service_identity.vpcaccess_identity_sa.email}"
}

resource "google_project_iam_member" "cloud_services" {
  count = local.grant_project_network_user ? 1 : 0

  project = var.vpc_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.serverless_project_id.number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "run_identity_services" {
  count = var.connector_on_host_project ? 0 : 1

  project = var.vpc_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${var.serverless_service_identity_email}"
}
