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
  value       = module.cloud_run_network.connector_id
  description = "VPC serverless connector ID."
}

output "keyring_self_link" {
  value       = module.cloud_run_security.keyring_self_link
  description = "Name of the Cloud KMS keyring."
}

output "key_self_link" {
  value       = module.cloud_run_security.key_self_link
  description = "Name of the Cloud KMS crypto key."
}

output "service_id" {
  value       = module.cloud_run_core.service_id
  description = "ID of the created service."
}

output "service_url" {
  value       = module.cloud_run_core.service_url
  description = "Url of the created service."
}

output "load_balancer_ip" {
  value       = module.cloud_run_core.load_balancer_ip
  description = "IP Address used by Load Balancer."
}

output "revision" {
  value       = module.cloud_run_core.revision
  description = "Deployed revision for the service."
}

output "service_status" {
  value       = module.cloud_run_core.service_status
  description = "Status of the created service."
}

output "domain_map_id" {
  value       = module.cloud_run_core.domain_map_id
  description = "Unique Identifier for the created domain map."
}

output "domain_map_status" {
  value       = module.cloud_run_core.domain_map_status
  description = "Status of Domain mapping."
}

output "gca_vpcaccess_sa" {
  value       = module.cloud_run_network.gca_vpcaccess_sa
  description = "Service Account for VPC Access."
}

output "cloud_services_sa" {
  value       = module.cloud_run_network.cloud_services_sa
  description = "Service Account for Cloud Run Service."
}

output "run_identity_services_sa" {
  value       = module.cloud_run_network.run_identity_services_sa
  description = "Service Identity to run services."
}
