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
  network_name = trimprefix(var.vpc_name, "vpc-") == var.vpc_name ? var.vpc_name : "vpc-${var.vpc_name}"
}

module "network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 5.2"
  project_id                             = module.serverless_project.project_id
  network_name                           = local.network_name
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "true"

  subnets = [
    {
      subnet_name           = "sb-restricted-${var.region}"
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "restricted subnet."
    }
  ]

  firewall_rules = [
    {
      name      = "fw-e-shared-restricted-65535-e-d-all-all-all"
      direction = "EGRESS"
      priority  = 65535

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }

      deny = [{
        protocol = "all"
        ports    = null
      }]

      ranges = ["0.0.0.0/0"]
    },
    {
      name      = "fw-e-shared-restricted-65534-e-a-allow-google-apis-all-tcp-443"
      direction = "EGRESS"
      priority  = 65534

      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      deny = []
      allow = [{
        protocol = "tcp"
        ports    = ["443"]
      }]

      ranges      = [module.private_service_connect.private_service_connect_ip]
      target_tags = ["allow-google-apis", "vpc-connector"]
    }
  ]
}

resource "google_dns_policy" "default_policy" {
  project                   = module.serverless_project.project_id
  name                      = "dns-default-policy"
  enable_inbound_forwarding = var.dns_enable_inbound_forwarding
  enable_logging            = var.dns_enable_logging
  networks {
    network_url = module.network.network_self_link
  }
}
