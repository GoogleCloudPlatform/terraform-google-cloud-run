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

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "name" {
  description = "The name of the Cloud Run job to create"
  type        = string
}

variable "location" {
  description = "Cloud Run job deployment location"
  type        = string
}

variable "image" {
  description = "GCR hosted image URL to deploy"
  type        = string
}

variable "exec" {
  description = "Whether to execute job after creation"
  type        = bool
  default     = false
}

variable "service_account_email" {
  type        = string
  description = "Service Account email needed for the job"
  default     = ""
}

variable "argument" {
  type        = list(string)
  description = "Arguments passed to the ENTRYPOINT command, include these only if image entrypoint needs arguments"
  default     = []
}

variable "container_command" {
  type        = list(string)
  description = "Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten"
  default     = []
}

variable "env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables (cleartext)"
  default     = []
}

variable "env_secret_vars" {
  type = list(object({
    name = string
    value_source = set(object({
      secret_key_ref = object({
        secret  = string
        version = optional(string, "latest")
      })
    }))
  }))
  description = "Environment variables (Secret Manager)"
  default     = []
}

variable "launch_stage" {
  type        = string
  description = "The launch stage. (see https://cloud.google.com/products#product-launch-stages). Defaults to GA."
  default     = ""
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "A set of key/value label pairs to assign to the Cloud Run job."
}

variable "max_retries" {
  type        = number
  default     = null
  description = "Number of retries allowed per Task, before marking this Task failed."
}

variable "parallelism" {
  type        = number
  default     = null
  description = "Specifies the maximum desired number of tasks the execution should run at given time. Must be <= taskCount."
}

variable "task_count" {
  type        = number
  default     = null
  description = "Specifies the desired number of tasks the execution should run."
}

variable "volumes" {
  type = list(object({
    name = string
    cloud_sql_instance = object({
      instances = set(string)
    })
  }))
  description = "A list of Volumes to make available to containers."
  default     = []
}

variable "volume_mounts" {
  type = list(object({
    name       = string
    mount_path = string
  }))
  description = "Volume to mount into the container's filesystem."
  default     = []
}

variable "vpc_access" {
  type = object({
    connector = optional(string)
    egress    = optional(string)
    network_interfaces = optional(object({
      network    = optional(string)
      subnetwork = optional(string)
      tags       = optional(list(string))
    }))
  })
  description = "Configure this to enable your service to send traffic to a Virtual Private Cloud. Set egress to ALL_TRAFFIC or PRIVATE_RANGES_ONLY. Choose a connector or network_interfaces (for direct VPC egress). For details: https://cloud.google.com/run/docs/configuring/connecting-vpc"
  default     = null
}

variable "limits" {
  type = object({
    cpu    = optional(string)
    memory = optional(string)
  })
  description = "Resource limits to the container"
  default     = null
}

variable "timeout" {
  type        = string
  description = "Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers."
  default     = "600s"
  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]{1,9})?s$", var.timeout))
    error_message = "The value must be a duration in seconds with up to nine fractional digits, ending with 's'. Example: \"3.5s\"."
  }
}

variable "cloud_run_deletion_protection" {
  type        = bool
  description = "This field prevents Terraform from destroying or recreating the Cloud Run v2 Jobs and Services"
  default     = true
}
