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

output "vpc_project_id" {
  value       = var.vpc_project_id
  description = "The project where VPC Connector is going to be deployed."
}

output "project_id" {
  value       = var.serverless_project_id
  description = "The project where Cloud Run will be created."
}

output "kms_project_id" {
  value       = var.kms_project_id
  description = "The project where KMS will be created."
}

output "keyring_name" {
  value       = local.cloudrun_keyring_name
  description = "Keyring name."
}

output "key_name" {
  value       = local.cloudrun_key_name
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

output "policy_for" {
  description = "Policy Root: set one of the following values to determine where the policy is applied. Possible values: [\"project\", \"folder\", \"organization\"]."
  value       = var.policy_for
}

output "folder_id" {
  description = "The folder ID to apply the policy to."
  value       = var.folder_id
}

output "organization_id" {
  description = "The organization ID to apply the policy to."
  value       = var.organization_id
}

output "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  value       = var.domain
}

output "shared_vpc_name" {
  description = "Shared VPC name which is going to be re-used to create Serverless Connector."
  value       = var.shared_vpc_name
}
