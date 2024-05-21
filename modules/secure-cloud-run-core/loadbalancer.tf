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

locals {
  cloud_armor_id = var.create_cloud_armor_policies ? google_compute_security_policy.cloud-armor-security-policy[0].id : "projects/${var.project_id}/global/securityPolicies/${var.cloud_armor_policies_name}"
}

module "lb-http" {
  source                          = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version                         = "~> 11.0"
  name                            = var.lb_name
  project                         = var.project_id
  ssl                             = true
  managed_ssl_certificate_domains = var.ssl_certificates.generate_certificates_for_domains
  ssl_certificates                = var.ssl_certificates.ssl_certificates_self_links
  create_ssl_certificate          = length(var.ssl_certificates.generate_certificates_for_domains) == 0 ? true : false
  https_redirect                  = false
  http_forward                    = false

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn              = false
      security_policy         = local.cloud_armor_id
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = true
        sample_rate = null
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "serverless-neg"
  project               = var.project_id
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = var.service_name
  }
}

resource "google_compute_security_policy" "cloud-armor-security-policy" {
  count   = var.create_cloud_armor_policies ? 1 : 0
  project = var.project_id
  name    = "cloud-armor-waf-policy"
  dynamic "rule" {
    for_each = var.default_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description
      match {
        versioned_expr = rule.value.versioned_expr
        config {
          src_ip_ranges = rule.value.src_ip_ranges
        }
      }
    }
  }
  dynamic "rule" {
    for_each = var.owasp_rules
    content {
      action   = rule.value.action
      priority = rule.value.priority
      match {
        expr {
          expression = rule.value.expression
        }
      }
    }
  }
}
