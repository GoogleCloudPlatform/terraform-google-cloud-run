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
  tags = ["vpc-connector"]
}

module "firewall_rules" {
  count = var.connector_on_host_project ? 0 : 1

  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.vpc_project_id
  network_name = var.shared_vpc_name

  rules = [{
    name                    = "serverless-to-vpc-connector"
    direction               = "INGRESS"
    ranges                  = ["107.178.230.64/26", "35.199.224.0/19"]
    target_tags             = local.tags
    allow = [{
      protocol = "icmp"
    },
    {
      protocol = "tcp"
      ports    = ["667"]
    },
    {
      protocol = "udp"
      ports    = ["665", "666"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "vpc-connector-to-serverless"
    direction               = "EGRESS"
    ranges                  = ["107.178.230.64/26", "35.199.224.0/19"]
    target_tags             = local.tags
    allow = [{
      protocol = "icmp"
    },
    {
      protocol = "tcp"
      ports    = ["667"]
    },
    {
      protocol = "udp"
      ports    = ["665", "666"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "vpc-connector-to-lb"
    direction               = "EGRESS"
    ranges                  = []
    target_tags             = local.tags
    allow = [{
      protocol = "tcp"
      ports    = ["80"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "vpc-connector-health-checks"
    direction               = "INGRESS"
    ranges                  = ["130.211.0.0/22", "35.191.0.0/16", "108.170.220.0/23"]
    target_tags             = local.tags
    allow = [{
      protocol = "tcp"
      ports    = ["667"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "vpc-connector-requests"
    direction               = "INGRESS"
    ranges                  = []
    source_tags             = local.tags
    allow = [{
      protocol = "icmp"
    },
    {
      protocol = "tcp"
    },
    {
      protocol = "udp"
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}
