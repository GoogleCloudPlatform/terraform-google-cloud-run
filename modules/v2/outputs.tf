/**
 * Copyright 2024 Google LLC
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
  value       = google_cloud_run_v2_service.main.project
  description = "Google Cloud project in which the service was created"
}

output "service_uri" {
  value       = google_cloud_run_v2_service.main.uri
  description = "The main URI in which this Service is serving traffic."
}

output "service_id" {
  value       = google_cloud_run_v2_service.main.id
  description = "Unique Identifier for the created service with format projects/{{project}}/locations/{{location}}/services/{{name}}"
}

output "service_name" {
  value       = google_cloud_run_v2_service.main.name
  description = "Name of the created service"
}

output "location" {
  value       = google_cloud_run_v2_service.main.location
  description = "Location in which the Cloud Run service was created"
}

output "creator" {
  value       = google_cloud_run_v2_service.main.creator
  description = "Email address of the authenticated creator."
}

output "last_modifier" {
  value       = google_cloud_run_v2_service.main.last_modifier
  description = "Email address of the last authenticated modifier."
}

output "observed_generation" {
  value       = google_cloud_run_v2_service.main.observed_generation
  description = "The generation of this Service currently serving traffic."
}

output "latest_ready_revision" {
  value       = google_cloud_run_v2_service.main.latest_ready_revision
  description = "Name of the latest revision that is serving traffic. See comments in reconciling for additional information on reconciliation process in Cloud Run."
}

output "latest_created_revision" {
  value       = google_cloud_run_v2_service.main.latest_created_revision
  description = "Name of the last created revision. See comments in reconciling for additional information on reconciliation process in Cloud Run."
}

output "effective_annotations" {
  value       = google_cloud_run_v2_service.main.effective_annotations
  description = "All of annotations (key/value pairs) present on the resource in GCP, including the annotations configured through Terraform, other clients and services."
}

output "traffic_statuses" {
  value       = google_cloud_run_v2_service.main.traffic_statuses
  description = "Detailed status information for corresponding traffic targets."
}

output "service_account_id" {
  description = "Service account id and email"
  value       = local.service_account_output
}

output "apphub_service_uri" {
  value = {
    service_uri = "//run.googleapis.com/${google_cloud_run_v2_service.main.id}"
    service_id  = substr("${var.service_name}-${md5("${var.location}-${var.project_id}")}", 0, 63)
  }
  description = "Service URI in CAIS style to be used by Apphub."
}
