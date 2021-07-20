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

// service
variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service to create"
  type        = string
}

variable "location" {
  description = "Cloud Run service deployment location"
  type        = string
}

variable "image" {
  description = "GCR hosted image URL to deploy"
  type        = string
}

variable "generate_revision_name" {
  type        = bool
  description = "Option to enable revision name generation"
  default     = true
}

variable "traffic_split" {
  type = list(object({
    latest_revision = bool
    percent         = number
    revision_name   = string
  }))
  description = "Managing traffic routing to the service"
  default = [{
    latest_revision = true
    percent         = 100
    revision_name   = "v1-0-0"
  }]
}

variable "service_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the service"
  default     = {}
}

variable "service_annotations" {
  type        = map(string)
  description = "Annotations to the service. Acceptable values all, internal, internal-and-cloud-load-balancing"
  default = {
    "run.googleapis.com/ingress" = "all"
  }
}

// Metadata
variable "template_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the container metadata"
  default     = {}
}

variable "template_annotations" {
  type        = map(string)
  description = "Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate)"
  default = {
    "run.googleapis.com/client-name"   = "terraform"
    "generated-by"                     = "terraform"
    "autoscaling.knative.dev/maxScale" = 2
    "autoscaling.knative.dev/minScale" = 1
  }
}

// template spec
variable "container_concurrency" {
  type        = number
  description = "Concurrent request limits to the service"
  default     = 0
}

variable "timeout_seconds" {
  type        = number
  description = "Timeout for each request"
  default     = 120
}

variable "service_account_email" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "volumes" {
  type = list(object({
    name = string
    secret = set(object({
      secret_name = string
      items       = map(string)
    }))
  }))
  description = "[Beta] Volumes needed for environment variables (when using secret)"
  default     = []
}

# template spec container
# resources
# cpu = (core count * 1000)m
# memory = (size) in Mi/Gi
variable "limits" {
  type        = map(string)
  description = "Resource limits to the container"
  default     = {}
}
variable "requests" {
  type        = map(string)
  description = "Resource requests to the container"
  default     = {}
}

variable "ports" {
  type = object({
    name = string
    port = number
  })
  description = "Port which the container listens to (http1 or h2c)"
  default = {
    name = "http1"
    port = 8080
  }
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
    value_from = set(object({
      secret_key_ref = map(string)
    }))
  }))
  description = "[Beta] Environment variables (Secret Manager)"
  default     = []
}

variable "volume_mounts" {
  type = list(object({
    mount_path = string
    name       = string
  }))
  description = "[Beta] Volume Mounts to be attached to the container (when using secret)"
  default     = []
}

// Domain Mapping
variable "verified_domain_name" {
  type        = string
  description = "Custom Domain Name"
  default     = ""
}

variable "force_override" {
  type        = bool
  description = "Option to force override existing mapping"
  default     = false
}

variable "certificate_mode" {
  type        = string
  description = "The mode of the certificate (NONE or AUTOMATIC)"
  default     = "NONE"
}

variable "domain_map_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the Domain mapping"
  default     = {}
}

variable "domain_map_annotations" {
  type        = map(string)
  description = "Annotations to the domain map"
  default     = {}
}

// IAM
variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access to the service"
  default     = []
}
