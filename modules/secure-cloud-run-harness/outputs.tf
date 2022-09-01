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

output "serverless_folder_id" {
  value       = google_folder.fld_serverless.name
  description = "The folder created to alocate Serverless infra."
}

output "serverless_project_id" {
  value       = module.serverless_project.project_id
  description = "Project ID of the project created to deploy Cloud Run."
}

output "serverless_project_number" {
  value       = module.serverless_project.project_number
  description = "Project number of the project created to deploy Cloud Run."
}

output "security_project_id" {
  value       = module.security_project.project_id
  description = "Project ID of the project created for KMS and Artifact Register."
}

output "security_project_number" {
  value       = module.security_project.project_number
  description = "Project number of the project created for KMS and Artifact Register."
}

output "service_account_email" {
  value       = module.service_accounts.email
  description = "The email of the Service Account created to be used by Cloud Run."
}

output "service_vpc" {
  value       = module.network.network
  description = "The network created for Cloud Run."
}

output "service_subnets" {
  value = module.network.subnets_names
}

output "artifact_registry_repository_id" {
  value       = google_artifact_registry_repository.repo.id
  description = "The Artifact Registry Repository full identifier where the images should be stored."
}

output "artifact_registry_repository_name" {
  value       = google_artifact_registry_repository.repo.repository_id
  description = "The Artifact Registry Repository last part of the repository name where the images should be stored."
}

output "cloud_run_service_identity_email" {
  value       = google_project_service_identity.serverless_sa.email
  description = "The Cloud Run Service Identity email."
}
