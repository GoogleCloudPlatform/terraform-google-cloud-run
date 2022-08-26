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

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "serverless_project_id" {
  description = "The project where cloud run is going to be deployed."
  type        = string
}

variable "cloud_run_sa" {
  description = "Service account to be used on Cloud Run."
  type        = string
}

variable "vpc_project_id" {
  description = "The project where shared vpc is."
  type        = string
}

variable "shared_vpc_name" {
  description = "Shared VPC name which is going to be re-used to create Serverless Connector."
  type        = string
}

variable "kms_project_id" {
  description = "The project where KMS will be created."
  type        = string
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`. Modify the default value below for your `domain` name"
  type        = string
}

variable "artifact_registry_repository_project_id" {
  description = "Artifact Registry Repository Project ID to grant serverless identity viewer role."
  type        = string
}

variable "artifact_registry_repository_location" {
  description = "Artifact Registry Repository location to grant serverless identity viewer role."
  type        = string
}

variable "artifact_registry_repository_name" {
  description = "Artifact Registry Repository name to grant serverless identity viewer role"
  type        = string
}
