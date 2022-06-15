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
  description = "Preconfigured rules for SQLi, XSS, LFI, RCE, RFI, Scannerdetection, Protocolattack and Sessionfixation."
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

variable "region" {
  description = "Location for load balancer and Cloud Run resources."
  type        = string
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`. Modify the default value below for your `domain` name."
  type        = string
  default     = "my-domain.com"
}

variable "lb_name" {
  description = "Name for load balancer and associated resources."
  default     = "tf-cr-lb"
}

variable "location" {
  description = "The location where resources are going to be deployed."
  type        = string
}

variable "serverless_project_id" {
  description = "The project where cloud run is going to be deployed."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service to create."
  type        = string
}

variable "image" {
  description = "GCR hosted image URL to deploy."
  type        = string
}

variable "cloud_run_sa" {
  description = "Service account to be used on Cloud Run."
  type        = string
}

variable "vpc_connector_id" {
  description = "VPC Connector id in the forma projects/PROJECT/locations/LOCATION/connectors/NAME."
  type        = string
}

variable "encryption_key" {
  description = "CMEK encryption key self-link expected in the format projects/PROJECT/locations/LOCATION/keyRings/KEY-RING/cryptoKeys/CRYPTO-KEY."
  type        = string
}

variable "env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables (cleartext)."
  default     = []
}

variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users."
  default     = []
}
