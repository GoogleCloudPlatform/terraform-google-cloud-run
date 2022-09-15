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

resource "google_compute_subnetwork" "vpc_subnetwork" {
  count = var.create_subnet ? 1 : 0

  name                     = var.subnet_name
  project                  = var.vpc_project_id
  network                  = var.shared_vpc_name
  ip_cidr_range            = var.ip_cidr_range
  region                   = var.location
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = var.flow_sampling
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

module "serverless_connector" {
  source  = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version = "~> 5.0"

  project_id = var.connector_on_host_project ? var.vpc_project_id : var.serverless_project_id
  vpc_connectors = [{
    name            = var.connector_name
    region          = var.location
    subnet_name     = var.subnet_name
    host_project_id = var.vpc_project_id
    machine_type    = "e2-micro"
    min_instances   = 2
    max_instances   = 7
    max_throughput  = 700
    }
  ]
  depends_on = [
    google_project_iam_member.gca_sa_vpcaccess,
    google_project_iam_member.cloud_services,
    google_project_iam_member.run_identity_services,
    google_compute_subnetwork.vpc_subnetwork
  ]
}
