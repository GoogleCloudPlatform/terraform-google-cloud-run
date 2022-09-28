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

output "kms_project_id" {
  value       = module.kms_project.project_id
  description = "The project where KMS will be created."
}

output "serverless_project_id" {
  value       = module.serverless_project.project_id
  description = "The project where cloud run is going to be deployed."
}

output "vpc_project_id" {
  value       = data.terraform_remote_state.sfb-network-prod.outputs.restricted_host_project_id
  description = "The project where Shared VPC is hosted."
}

output "cloud_run_sa" {
  value       = module.serverless_project.service_account_email
  description = "Service account created in the Secure Cloud Run project."
}

output "connector_id" {
  value       = module.secure_cloud_run.connector_id
  description = "VPC serverless connector ID."
}

output "load_balancer_ip" {
  value       = module.secure_cloud_run.load_balancer_ip
  description = "IP Address used by Load Balancer."
}

output "revision" {
  value       = module.secure_cloud_run.revision
  description = "Deployed revision for the service."
}

output "service_url" {
  value       = module.secure_cloud_run.service_url
  description = "The URL on which the deployed service is available."
}

output "service_id" {
  value       = module.secure_cloud_run.service_id
  description = "Unique Identifier for the created service."
}

output "service_status" {
  value       = module.secure_cloud_run.service_status
  description = "Status of the created service."
}

output "domain_map_id" {
  value       = module.secure_cloud_run.domain_map_id
  description = "Unique Identifier for the created domain map."
}

output "domain_map_status" {
  value       = module.secure_cloud_run.domain_map_status
  description = "Status of Domain mapping."
}

output "keyring_name" {
  value       = module.secure_cloud_run.keyring_name
  description = "Keyring name."
}

output "key_name" {
  value       = module.secure_cloud_run.key_name
  description = "Key name."
}

output "gca_vpcaccess_sa" {
  value       = module.secure_cloud_run.gca_vpcaccess_sa
  description = "Service Account for VPC Access."
}

output "cloud_services_sa" {
  value       = module.secure_cloud_run.cloud_services_sa
  description = "Service Account for Cloud Run Service."
}

output "run_identity_services_sa" {
  value       = module.secure_cloud_run.run_identity_services_sa
  description = "Service Identity to run services."
}

output "folder_id" {
  description = "The folder ID to apply the policy to."
  value       = module.secure_cloud_run.folder_id
}

output "organization_id" {
  description = "The organization ID to apply the policy to."
  value       = module.secure_cloud_run.organization_id
}

output "domain" {
  value = module.secure_cloud_run.domain
}

output "shared_vpc_name" {
  value = module.secure_cloud_run.shared_vpc_name
}

output "terraform_sa_email" {
  value = local.terraform_sa_email
}

output "policy_for" {
  description = "Policy Root: set one of the following values to determine where the policy is applied. Possible values: [\"project\", \"folder\", \"organization\"]."
  value       = module.secure_cloud_run.policy_for
}
