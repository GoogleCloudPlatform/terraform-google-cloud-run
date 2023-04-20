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

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "network_project_id" {
  value       = [for network in module.network : network.project_id]
  description = "Project ID of the project created to host the Cloud Run Network."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "serverless_project_ids" {
  value       = [for project in module.serverless_project : project.project_id]
  description = "Project ID of the projects created to deploy Cloud Run."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "serverless_project_numbers" {
  value       = { for project in module.serverless_project : project.project_id => project.project_number }
  description = "Project number of the projects created to deploy Cloud Run."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "security_project_id" {
  value       = module.security_project.project_id
  description = "Project ID of the project created for KMS and Artifact Register."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "security_project_number" {
  value       = module.security_project.project_number
  description = "Project number of the project created for KMS and Artifact Register."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "service_account_email" {
  value       = { for project in module.serverless_project : project.project_id => project.service_account_email }
  description = "The email of the Service Account created to be used by Cloud Serverless."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "service_vpc" {
  value       = [for network in module.network : network.network]
  description = "The network created for Cloud Serverless."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "service_subnet" {
  value       = [for network in module.network : network.subnets_names[0]]
  description = "The sub-network name created in harness."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "artifact_registry_repository_id" {
  value       = google_artifact_registry_repository.repo.id
  description = "The Artifact Registry Repository full identifier where the images should be stored."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "artifact_registry_repository_name" {
  value       = google_artifact_registry_repository.repo.repository_id
  description = "The Artifact Registry Repository last part of the repository name where the images should be stored."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "cloud_serverless_service_identity_email" {
  value       = { for project in module.serverless_project : project.project_id => project.cloud_serverless_service_identity_email }
  description = "The Cloud Run Service Identity email."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "restricted_service_perimeter_name" {
  value       = module.regular_service_perimeter.perimeter_name
  description = "Service Perimeter name."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "restricted_access_level_name" {
  value       = module.access_level_members.name
  description = "Access level name."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}

output "cloudfunction_source_bucket" {
  value       = var.serverless_type == "CLOUD_RUN" ? {} : { for bucket in module.cloudfunction_source_bucket : bucket.bucket.project => bucket.bucket }
  description = "Cloud Function Source Bucket."

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}
