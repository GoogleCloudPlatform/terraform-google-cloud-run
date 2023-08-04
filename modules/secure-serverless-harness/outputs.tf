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
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "network_project_id" {
  value       = [for network in module.network : network.project_id]
  description = "Project ID of the project created to host the Cloud Run Network."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "serverless_project_ids" {
  value       = [for project in module.serverless_project : project.project_id]
  description = "Project ID of the projects created to deploy Cloud Run."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "serverless_project_numbers" {
  value       = { for project in module.serverless_project : project.project_id => project.project_number }
  description = "Project number of the projects created to deploy Cloud Run."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "security_project_id" {
  value       = module.security_project.project_id
  description = "Project ID of the project created for KMS and Artifact Register."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "security_project_number" {
  value       = module.security_project.project_number
  description = "Project number of the project created for KMS and Artifact Register."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "service_account_email" {
  value       = { for project in module.serverless_project : project.project_id => project.service_account_email }
  description = "The email of the Service Account created to be used by Cloud Serverless."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "service_vpc" {
  value       = [for network in module.network : network.network]
  description = "The network created for Cloud Serverless."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "service_subnet" {
  value       = [for network in module.network : network.subnets_names[0]]
  description = "The sub-network name created in harness."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "artifact_registry_repository_id" {
  value       = var.base_serverless_api == "run.googleapis.com" ? google_artifact_registry_repository.repo[0].id : ""
  description = "The Artifact Registry Repository full identifier where the images should be stored."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "artifact_registry_repository_name" {
  value       = var.base_serverless_api == "run.googleapis.com" ? google_artifact_registry_repository.repo[0].repository_id : ""
  description = "The Artifact Registry Repository last part of the repository name where the images should be stored."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "cloud_serverless_service_identity_email" {
  value       = { for project in module.serverless_project : project.project_id => project.cloud_serverless_service_identity_email }
  description = "The Cloud Run Service Identity email."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "access_context_manager_policy_id" {
  value       = local.access_context_manager_policy_id
  description = "Access Context Manager ID."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "restricted_service_perimeter_name" {
  value       = module.regular_service_perimeter.perimeter_name
  description = "Service Perimeter name."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "restricted_access_level_name" {
  value       = module.access_level_members.name
  description = "Access level name."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "restricted_access_level_name_id" {
  value       = module.access_level_members.name_id
  description = "Access level name id."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

output "artifact_registry_key" {
  value       = module.artifact_registry_kms.keys[var.key_name]
  description = "Artifact Registry KMS Key."

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}
