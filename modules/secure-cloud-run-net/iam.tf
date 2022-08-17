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

resource "google_project_service_identity" "run_identity_sa" {
  provider = google-beta

  project = var.serverless_project_id
  service = "run.googleapis.com"
}

resource "google_project_iam_member" "gca_sa_vpcaccess" {
  count = var.connector_on_host_project ? 0 : 1

  project = var.vpc_project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_project_service_identity.vpcaccess_identity_sa.email}"
}

resource "google_project_iam_member" "cloud_services" {
  count = var.connector_on_host_project ? 0 : 1

  project = var.vpc_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.serverless_project_id.number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "run_identity_services" {
  count = var.connector_on_host_project ? 1 : 0

  project = var.vpc_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${google_project_service_identity.run_identity_sa.email}"
}
