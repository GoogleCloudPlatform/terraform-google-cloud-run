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

module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 3.0.0"

  project_id              = var.project_id
  network_name            = "cloud-run-vpc"
  auto_create_subnetworks = false

  shared_vpc_host = false
}

module "subnet" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 3.0.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  subnets = [
    {
      subnet_name           = "cloud-run-subnet"
      subnet_ip             = "10.10.0.0/28"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Cloud Run VPC Connector Subnet"
    }
  ]
}

module "serverless_connector" {
  source = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"

  project_id = var.project_id
  vpc_connectors = [{
    name            = "central-serverless"
    region          = "us-central1"
    subnet_name     = "${module.subnet.subnets["us-central1/cloud-run-subnet"]["name"]}"
    host_project_id = var.project_id
    machine_type    = "e2-micro"
    min_instances   = 2
    max_instances   = 3
  }]
}

module "cloud_run" {
  source = "../../"

  service_name           = "ci-cloud-run-sc"
  project_id             = var.project_id
  location               = "us-central1"
  generate_revision_name = true
  image                  = "us-docker.pkg.dev/cloudrun/container/hello"

  template_annotations = {
    "autoscaling.knative.dev/maxScale"        = 4
    "autoscaling.knative.dev/minScale"        = 2
    "run.googleapis.com/vpc-access-connector" = element(tolist(module.serverless_connector.connector_ids), 1)
    "run.googleapis.com/vpc-access-egress"    = "all-traffic"
  }
}
