/**
 * Copyright 2025 Google LLC
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

variable "branch_name" {
  description = "The branch to be used for CD"
  type        = string
  default     = "main"
}

variable "github_auth_token_secret" {
  description = "A SecretManager resource containing the OAuth token that authorizes the Cloud Build connection"
  validation {
    condition     = can(regex("^projects/*/secrets/*/versions/*$", var.github_auth_token_secret))
    error_message = "value should follow format 'projects/*/secrets/*/versions/*'"
  }
  type = string
}

variable "github_repo" {
  description = "URI of the Git repository for CD"
  type        = string
}

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "service_name" {
  description = "Name of the new Cloud Run service"
  type        = string
  default     = "example_service_with_cd"
}
