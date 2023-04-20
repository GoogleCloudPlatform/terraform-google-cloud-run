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
  value       = tolist(module.serverless_connector.connector_ids)[0]
  description = "VPC serverless connector ID."
}

output "gca_vpcaccess_sa" {
  value       = google_project_service_identity.vpcaccess_identity_sa.email
  description = "Google APIs Service Agent for VPC Access."
}

output "cloud_services_sa" {
  value       = "${data.google_project.serverless_project_id.number}@cloudservices.gserviceaccount.com"
  description = "Google APIs service agent."
}

output "subnet_name" {
  value       = local.subnet_name
  description = "The name of the sub-network used to create VPC Connector."
}
