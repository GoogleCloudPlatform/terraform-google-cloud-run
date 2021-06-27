/**
 * Copyright 2021 Google LLC
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

output "service_name" {
  value       = google_cloud_run_service.main.name
  description = "Name of the created service"
}

output "revision" {
  value       = google_cloud_run_service.main.status[0].latest_ready_revision_name
  description = "Deployed revision for the service"
}

output "service_url" {
  value       = google_cloud_run_service.main.status[0].url
  description = "The URL on which the deployed service is available"
}

output "project_id" {
  value       = google_cloud_run_service.main.project
  description = "Google Cloud project in which the service was created"
}

output "location" {
  value       = google_cloud_run_service.main.location
  description = "Location in which the Cloud Run service was created"
}

output "service_id" {
  value       = google_cloud_run_service.main.id
  description = "Unique Identifier for the created service"
}

output "service_status" {
  value       = google_cloud_run_service.main.status[0].conditions[0].type
  description = "Status of the created service"
}

output "domain_map_id" {
  value       = google_cloud_run_domain_mapping.domain_map.*.id
  description = "Unique Identifier for the created domain map"
}

output "domain_map_status" {
  value       = google_cloud_run_domain_mapping.domain_map.*.status
  description = "Status of Domain mapping"
}
