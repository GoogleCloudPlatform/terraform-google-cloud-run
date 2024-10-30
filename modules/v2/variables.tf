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

variable "description" {
  description = "Cloud Run service description. This field currently has a 512-character limit."
  type        = string
  default     = null
}

variable "traffic" {
  type = list(object({
    type     = optional(string, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
    percent  = optional(number, 100)
    revision = optional(string, null)
    tag      = optional(string, null)
  }))
  description = "Specifies how to distribute traffic over a collection of Revisions belonging to the Service. If traffic is empty or not provided, defaults to 100% traffic to the latest Ready Revision."
  default     = []
}

variable "service_scaling" {
  type = object({
    min_instance_count = optional(number)
  })
  description = "Scaling settings that apply to the whole service"
  default     = null
}

variable "service_labels" {
  type        = map(string)
  description = "Unstructured key value map that can be used to organize and categorize objects. For more information, visit https://cloud.google.com/resource-manager/docs/creating-managing-labels or https://cloud.google.com/run/docs/configuring/labels"
  default     = {}
}

variable "service_annotations" {
  type        = map(string)
  description = "Unstructured key value map that may be set by external tools to store and arbitrary metadata. They are not queryable and should be preserved when modifying objects. Refer https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#annotations"
  default     = {}
}

variable "client" {
  type = object({
    name    = optional(string, null)
    version = optional(string, null)
  })
  description = "Arbitrary identifier for the API client and version identifier"
  default     = {}
}

variable "ingress" {
  type        = string
  description = "Provides the ingress settings for this Service. On output, returns the currently observed ingress settings, or INGRESS_TRAFFIC_UNSPECIFIED if no revision is active."
  default     = "INGRESS_TRAFFIC_ALL"

  validation {
    condition     = contains(["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY", "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.ingress)
    error_message = "Allowed values for ingress are \"INGRESS_TRAFFIC_ALL\", \"INGRESS_TRAFFIC_INTERNAL_ONLY\", or \"INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER\"."
  }
}

variable "launch_stage" {
  type        = string
  description = "The launch stage as defined by Google Cloud Platform Launch Stages. Cloud Run supports ALPHA, BETA, and GA. If no value is specified, GA is assumed."
  default     = "GA"

  validation {
    condition     = contains(["UNIMPLEMENTED", "PRELAUNCH", "EARLY_ACCESS", "ALPHA", "BETA", "GA", "DEPRECATED"], var.launch_stage)
    error_message = "Allowed values for launch_stage are \"UNIMPLEMENTED\", \"PRELAUNCH\", or \"EARLY_ACCESS\", or \"DEPRECATED\", or \"ALPHA\", or \"BETA\", or \"GA\"."
  }
}

variable "custom_audiences" {
  type        = list(string)
  description = "One or more custom audiences that you want this service to support. Specify each custom audience as the full URL in a string. Refer https://cloud.google.com/run/docs/configuring/custom-audiences"
  default     = null
}

variable "binary_authorization" {
  type = object({
    breakglass_justification = optional(bool) # If present, indicates to use Breakglass using this justification. If useDefault is False, then it must be empty. For more information on breakglass, see https://cloud.google.com/binary-authorization/docs/using-breakglass
    use_default              = optional(bool) #If True, indicates to use the default project's binary authorization policy. If False, binary authorization will be disabled.
  })
  description = "Settings for the Binary Authorization feature."
  default     = null
}

// Template
variable "revision" {
  description = "The unique name for the revision. If this field is omitted, it will be automatically generated based on the Service name"
  type        = string
  default     = null
}

variable "template_scaling" {
  type = object({
    min_instance_count = optional(number)
    max_instance_count = optional(number)
  })
  description = "Scaling settings for this Revision."
  default     = null
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
  description = "VPC Access configuration to use for this Task. For more information, visit https://cloud.google.com/run/docs/configuring/connecting-vpc"
  default     = null
}

variable "template_labels" {
  type        = map(string)
  description = "Unstructured key value map that can be used to organize and categorize objects. For more information, visit https://cloud.google.com/resource-manager/docs/creating-managing-labels or https://cloud.google.com/run/docs/configuring/labels"
  default     = {}
}

variable "template_annotations" {
  type        = map(string)
  description = "Unstructured key value map that may be set by external tools to store and arbitrary metadata. They are not queryable and should be preserved when modifying objects. Refer https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#annotations"
  default     = {}
}

variable "timeout" {
  type        = string
  description = "Max allowed time for an instance to respond to a request. A duration in seconds with up to nine fractional digits, ending with 's'"
  default     = null
}

variable "service_account" {
  type        = string
  description = "Email address of the IAM service account associated with the revision of the service"
  default     = null
}

variable "encryption_key" {
  description = "A reference to a customer managed encryption key (CMEK) to use to encrypt this container image."
  type        = string
  default     = null
}

variable "max_instance_request_concurrency" {
  type        = string
  description = "Sets the maximum number of requests that each serving instance can receive"
  default     = null
}

variable "session_affinity" {
  type        = string
  description = "Enables session affinity. For more information, go to https://cloud.google.com/run/docs/configuring/session-affinity"
  default     = null
}

variable "execution_environment" {
  type        = string
  description = "The sandbox environment to host this Revision."
  default     = "EXECUTION_ENVIRONMENT_GEN2"

  validation {
    condition     = contains(["EXECUTION_ENVIRONMENT_GEN1", "EXECUTION_ENVIRONMENT_GEN2"], var.execution_environment)
    error_message = "Allowed values for ingress are \"EXECUTION_ENVIRONMENT_GEN1\", \"EXECUTION_ENVIRONMENT_GEN2\"."
  }
}

variable "volumes" {
  type = list(object({
    name = string
    secret = optional(object({
      secret       = string
      default_mode = optional(string)
      items = optional(object({
        path    = string
        version = optional(string)
        mode    = optional(string)
      }))
    }))
    cloud_sql_instance = optional(object({
      instances = optional(list(string))
    }))
    empty_dir = optional(object({
      medium     = optional(string)
      size_limit = optional(string)
    }))
    gcs = optional(object({
      bucket    = string
      read_only = optional(string)
    }))
    nfs = optional(object({
      server    = string
      path      = string
      read_only = optional(string)
    }))
  }))
  description = "Volumes needed for environment variables (when using secret)"
  default     = []
}

// Containers
variable "containers" {
  type = list(object({
    container_name       = optional(string, null)
    container_image      = string
    working_dir          = optional(string, null)
    depends_on_container = optional(list(string), null)
    container_args       = optional(list(string), null)
    container_command    = optional(list(string), null)
    env_vars             = optional(map(string), {})
    env_secret_vars = optional(map(object({
      secret  = string
      version = string
    })), {})
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
    })), [])
    ports = optional(object({
      name           = optional(string, "http1")
      container_port = optional(number, 8080)
    }), {})
    resources = optional(object({
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
      cpu_idle          = optional(bool, true)
      startup_cpu_boost = optional(bool, false)
    }), {})
    startup_probe = optional(object({
      failure_threshold     = optional(number, null)
      initial_delay_seconds = optional(number, null)
      timeout_seconds       = optional(number, null)
      period_seconds        = optional(number, null)
      http_get = optional(object({
        path = optional(string)
        port = optional(string)
        http_headers = optional(list(object({
          name  = string
          value = string
        })), [])
      }), null)
      tcp_socket = optional(object({
        port = optional(number)
      }), null)
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }), null)
    }), null)
    liveness_probe = optional(object({
      failure_threshold     = optional(number, null)
      initial_delay_seconds = optional(number, null)
      timeout_seconds       = optional(number, null)
      period_seconds        = optional(number, null)
      http_get = optional(object({
        path = optional(string)
        port = optional(string)
        http_headers = optional(list(object({
          name  = string
          value = string
        })), null)
      }), null)
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }), null)
    }), null)
  }))
  description = "Map of container images for the service"
}

// IAM
variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access to the service"
  default     = []
}

variable "create_service_account" {
  type        = bool
  description = "Create a new service account for cloud run service"
  default     = true
}

variable "service_account_project_roles" {
  type        = list(string)
  description = "Roles to grant to the newly created cloud run SA in specified project. Should be used with create_service_account set to true and no input for service_account"
  default     = []
}

variable "deletion_protection" {
  description = "Whether Terraform will be prevented from destroying the service"
  type        = bool
  default     = false
}
