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

resource "google_compute_firewall" "serverless_to_vpc_connector" {
  count = var.connector_on_host_project ? 0 : 1

  project       = var.vpc_project_id
  name          = "serverless-to-vpc-connector"
  network       = var.shared_vpc_name
  direction     = "INGRESS"
  source_ranges = ["107.178.230.64/26", "35.199.224.0/19"]
  target_tags   = local.tags
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["667"]
  }

  allow {
    protocol = "udp"
    ports    = ["665", "666"]
  }
}

resource "google_compute_firewall" "vpc_connector_to_serverless" {
  count = var.connector_on_host_project ? 0 : 1

  project       = var.vpc_project_id
  name          = "vpc-connector-to-serverless"
  network       = var.shared_vpc_name
  direction     = "EGRESS"
  source_ranges = ["107.178.230.64/26", "35.199.224.0/19"]
  target_tags   = local.tags

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["667"]
  }

  allow {
    protocol = "udp"
    ports    = ["665", "666"]
  }
}

resource "google_compute_firewall" "vpc_connector_to_lb" {
  count = var.connector_on_host_project ? 0 : 1

  project     = var.vpc_project_id
  name        = "vpc-connector-to-lb"
  network     = var.shared_vpc_name
  direction   = "EGRESS"
  target_tags = local.tags

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "vpc_connector_health_checks" {
  count = var.connector_on_host_project ? 0 : 1

  project       = var.vpc_project_id
  name          = "vpc-connector-health-checks"
  network       = var.shared_vpc_name
  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "108.170.220.0/23"]
  target_tags   = local.tags

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["667"]
  }
}

resource "google_compute_firewall" "vpc_connector_requests" {
  count = var.connector_on_host_project ? 0 : 1

  project     = var.vpc_project_id
  name        = "vpc-connector-requests"
  network     = var.shared_vpc_name
  direction   = "INGRESS"
  source_tags = local.tags

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
}
