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

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "cloud_run_deletion_protection" {
  type        = bool
  description = "This field prevents Terraform from destroying or recreating the Cloud Run v2 Jobs and Services"
  default     = true
}

variable "build_config" {
  description = "Optional Cloud Build configuration for Cloud Run. This block enables building a container image from source using Cloud Build instead of specifying a prebuilt container image."
  type = object({
    source_location          = optional(string)
    function_target          = optional(string)
    image_uri                = optional(string)
    base_image               = optional(string)
    enable_automatic_updates = optional(bool)
    worker_pool              = optional(string)
    environment_variables    = optional(map(string))
    service_account          = optional(string)
  })
  default = null
}