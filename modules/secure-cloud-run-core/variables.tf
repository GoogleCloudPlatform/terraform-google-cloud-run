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
  description = "The project where cloud run is going to be deployed."
  type        = string
}

variable "location" {
  description = "The location where resources are going to be deployed."
  type        = string
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources (usually same as location)."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service to create."
  type        = string
}

variable "image" {
  description = "GAR hosted image URL to deploy."
  type        = string
}

variable "cloud_run_sa" {
  description = "Service account to be used on Cloud Run."
  type        = string
}

variable "execution_environment" {
  description = "The execution environment (e.g., EXECUTION_ENVIRONMENT_GEN2, EXECUTION_ENVIRONMENT_GEN1)."
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
}

variable "env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables."
  default     = []
}

variable "ports" {
  description = "Port which the container listens to."
  type = object({
    name = string
    port = number
  })
  default = {
    name = "http1"
    port = 8080
  }
}

variable "argument" {
  description = "Arguments passed to the ENTRYPOINT command."
  type        = list(string)
  default     = []
}

variable "container_command" {
  description = "Container entrypoint command."
  type        = list(string)
  default     = []
}

variable "limits" {
  description = "Resource limits (memory, cpu, nvidia.com/gpu)."
  type        = map(string)
  default     = null
}

variable "requests" {
  description = "Resource requests (memory, cpu). Note: Child module must be patched to support this field."
  type        = map(string)
  default     = {}
}

variable "container_concurrency" {
  description = "Concurrent request limits to the service."
  type        = number
  default     = null
}

variable "timeout_seconds" {
  description = "Timeout for each request in seconds."
  type        = number
  default     = 120
}

variable "startup_probe" {
  description = "Configuration for the startup probe."
  type = object({
    failure_threshold     = optional(number)
    initial_delay_seconds = optional(number)
    timeout_seconds       = optional(number)
    period_seconds        = optional(number)
    http_get = optional(object({
      path = optional(string)
      port = optional(number)
      http_headers = optional(list(object({
        name  = string
        value = string
      })))
    }))
    tcp_socket = optional(object({
      port = number
    }))
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }))
  })
  default = null
}

variable "liveness_probe" {
  description = "Configuration for the liveness probe."
  type = object({
    failure_threshold     = optional(number)
    initial_delay_seconds = optional(number)
    timeout_seconds       = optional(number)
    period_seconds        = optional(number)
    http_get = optional(object({
      path = optional(string)
      port = optional(number)
      http_headers = optional(list(object({
        name  = string
        value = string
      })))
    }))
    tcp_socket = optional(object({
      port = number
    }))
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }))
  })
  default = null
}

variable "ingress" {
  description = "Ingress traffic sources allowed to call the service."
  type        = string
  default     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

variable "vpc_connector_id" {
  description = "VPC Connector id. If provided, Direct VPC Egress settings are ignored."
  type        = string
  default     = null
}

variable "vpc_egress_value" {
  description = "Sets VPC Egress firewall rule (e.g. PRIVATE_RANGES_ONLY, ALL_TRAFFIC)."
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
}

variable "vpc_network_interface" {
  description = "List of network interfaces for Direct VPC Egress (Cloud Run v2)."
  type = object({
    network    = optional(string)
    subnetwork = optional(string)
    tags       = optional(list(string))
  })
  default = null
}

variable "encryption_key" {
  description = "CMEK encryption key self-link."
  type        = string
  default     = null
}

variable "lb_name" {
  description = "Name for load balancer and associated resources."
  type        = string
  default     = "tf-cr-lb"
}

variable "create_cloud_armor_policies" {
  type        = bool
  description = "When true, create Cloud Armor policies. When false, provide existing name."
  default     = true
}

variable "cloud_armor_policies_name" {
  type        = string
  description = "Existing Cloud Armor policy name if create_cloud_armor_policies is false."
  default     = null
}

variable "default_rules" {
  description = "Default rule for Cloud Armor."
  default = {
    default_rule = {
      action         = "allow"
      priority       = "2147483647"
      versioned_expr = "SRC_IPS_V1"
      src_ip_ranges  = ["*"]
      description    = "Default allow all rule"
    }
  }
  type = map(object({
    action         = string
    priority       = string
    versioned_expr = string
    src_ip_ranges  = list(string)
    description    = string
  }))
}

variable "owasp_rules" {
  description = "Additional Cloud Armor rules (SQLi, XSS, etc)."
  default = {
    rule_sqli = {
      action     = "deny(403)"
      priority   = "1000"
      expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
    }
    rule_xss = {
      action     = "deny(403)"
      priority   = "1001"
      expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
    }
    rule_lfi = {
      action     = "deny(403)"
      priority   = "1002"
      expression = "evaluatePreconfiguredExpr('lfi-v33-stable')"
    }
    rule_canary = {
      action     = "deny(403)"
      priority   = "1003"
      expression = "evaluatePreconfiguredExpr('rce-v33-stable')"
    }
    rule_rfi = {
      action     = "deny(403)"
      priority   = "1004"
      expression = "evaluatePreconfiguredExpr('rfi-v33-stable')"
    }
    rule_scannerdetection = {
      action     = "deny(403)"
      priority   = "1005"
      expression = "evaluatePreconfiguredExpr('scannerdetection-v33-stable')"
    }
    rule_protocolattack = {
      action     = "deny(403)"
      priority   = "1006"
      expression = "evaluatePreconfiguredExpr('protocolattack-v33-stable')"
    }
    rule_sessionfixation = {
      action     = "deny(403)"
      priority   = "1007"
      expression = "evaluatePreconfiguredExpr('sessionfixation-v33-stable')"
    }
  }
  type = map(object({
    action     = string
    priority   = string
    expression = string
  }))
}

variable "ssl_certificates" {
  type = object({
    ssl_certificates_self_links       = list(string)
    generate_certificates_for_domains = list(string)
  })
  validation {
    condition = (!(length(var.ssl_certificates.ssl_certificates_self_links) == 0 && length(var.ssl_certificates.generate_certificates_for_domains) == 0) ||
    !(length(var.ssl_certificates.ssl_certificates_self_links) > 0 && length(var.ssl_certificates.generate_certificates_for_domains) > 0))
    error_message = "You must provide a SSL Certificate self-link or at least one domain to a SSL Certificate be generated."
  }
  description = "A object with a list of domains to auto-generate SSL certificates or a list of SSL Certificates self-links."
}

variable "volume_mounts" {
  type = list(object({
    mount_path = string
    name       = string
  }))
  description = "Volume Mounts to be attached to the container."
  default     = []
}

variable "volumes" {
  description = "[Beta] Volumes needed for environment variables (when using secret)."
  type = list(object({
    name = string
    secret = set(object({
      secret_name = string
      items       = map(string)
    }))
  }))
  default = []
}

variable "generate_revision_name" {
  description = "Option to enable revision name generation."
  type        = bool
  default     = true
}

variable "min_scale_instances" {
  description = "Minimum number of container instances."
  type        = number
  default     = 0
}

variable "max_scale_instances" {
  description = "Maximum number of container instances."
  type        = number
  default     = 100
}

variable "traffic_split" {
  description = "Managing traffic routing to the service."
  type = list(object({
    latest_revision = optional(bool)
    percent         = number
    revision_name   = optional(string)
    tag             = optional(string)
  }))
  default = [{
    latest_revision = true
    percent         = 100
  }]
}

variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access."
  default     = []
}

variable "iap_members" {
  type        = list(string)
  description = "Users/SAs to be given IAP access (if IAP is enabled)."
  default     = []
}

variable "service_labels" {
  description = "Labels to assign to the service."
  type        = map(string)
  default     = {}
}

variable "template_labels" {
  description = "Labels to assign to the container metadata."
  type        = map(string)
  default     = {}
}

variable "verified_domain_name" {
  description = "List of custom Domain Name."
  type        = list(string)
  default     = []
}

variable "force_override" {
  description = "Option to force override existing mapping."
  type        = bool
  default     = false
}

variable "certificate_mode" {
  description = "The mode of the certificate (NONE or AUTOMATIC)."
  type        = string
  default     = "NONE"
}

variable "domain_map_labels" {
  description = "Labels to assign to the Domain mapping."
  type        = map(string)
  default     = {}
}

variable "domain_map_annotations" {
  description = "Annotations to the domain map."
  type        = map(string)
  default     = {}
}

variable "cloud_run_deletion_protection" {
  type        = bool
  description = "This field prevents Terraform from destroying or recreating the Cloud Run v2 Jobs and Services"
  default     = false
}

variable "enable_prometheus_sidecar" {
  type        = bool
  description = "Enable Prometheus sidecar in Cloud Run instance."
  default     = false
}

variable "gpu_zonal_redundancy_disabled" {
  type        = bool
  description = "True if GPU zonal redundancy is disabled on this revision."
  default     = false
}

variable "node_selector" {
  type = object({
    accelerator = string
  })
  description = "Node Selector describes the hardware requirements of the GPU resource. [More info](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#nested_template_node_selector)."
  default     = null
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
