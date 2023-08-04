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

output "project_id" {
  value       = module.serverless_project.project_id
  description = "Project ID of the project created to deploy Cloud Serverless."
}

output "project_number" {
  value       = module.serverless_project.project_number
  description = "Project number of the project created to deploy Cloud Serverless."
}

output "service_account_email" {
  value       = module.service_accounts.email
  description = "The service account created tin the project."
}

output "cloud_serverless_service_identity_email" {
  value       = google_project_service_identity.serverless_sa.email
  description = "The Cloud Serverless Service Identity email."
}

output "services_identities" {
  value = {
    "eventarc"      = google_project_service_identity.eventarc_sa.email,
    "cloudbuild"    = google_project_service_identity.cloudbuild_sa.email,
    "gcs"           = data.google_storage_project_service_account.gcs_account.email_address,
    "serverless"    = google_project_service_identity.serverless_sa.email,
    "cloudservices" = "${module.serverless_project.project_number}@cloudservices.gserviceaccount.com"
  }
  description = "Services Identities for the serverless project."
}
