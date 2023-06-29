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

variable "billing_account" {
  description = "The ID of the billing account to associate this project with."
  type        = string
}

variable "base_serverless_api" {
  description = "This variable will enable Cloud Function or Cloud Run specific resources. Cloud Run API will be used for the terraform-google-cloud-run repository while Cloud Function API will be used in the terraform-google-cloud-functions repository. It supports only run.googleapis.com or cloudfunctions.googleapis.com"
  type        = string

  validation {
    condition     = contains(["run.googleapis.com", "cloudfunctions.googleapis.com"], var.base_serverless_api)
    error_message = "Unsupported value for base_serverless_api"
  }
}

variable "network_project_id" {
  description = "The network project_id when using Shared VPC."
  type        = string
  default     = ""
}

variable "project_name" {
  description = "The name to give the Cloud Serverless project."
  type        = string
}

variable "org_id" {
  description = "The organization ID."
  type        = string
}

variable "activate_apis" {
  description = "The APIs to enabled when creating the project."
  type        = list(string)
}

variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed"
  default     = false
  type        = bool
}

variable "folder_name" {
  description = "The folder name."
  type        = string
}

variable "service_account_project_roles" {
  type        = list(string)
  description = "Common roles to apply to the Cloud Run service account in the serverless project."
  default     = []
}
