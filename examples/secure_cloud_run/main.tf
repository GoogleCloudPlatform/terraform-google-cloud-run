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
  suffix                = var.resource_names_suffix == null ? "" : "-${var.resource_names_suffix}"
  cloudrun_key_name     = "cloud-run${local.suffix}"
  cloudrun_keyring_name = "cloud-run-keyring${local.suffix}"
}

module "secure_cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-run"
  version = "~> 0.13"

  connector_name              = "con-run"
  subnet_name                 = "vpc-subnet"
  vpc_project_id              = var.vpc_project_id
  serverless_project_id       = var.serverless_project_id
  kms_project_id              = var.kms_project_id
  shared_vpc_name             = var.shared_vpc_name
  ip_cidr_range               = var.ip_cidr_range
  key_name                    = local.cloudrun_key_name
  keyring_name                = local.cloudrun_keyring_name
  prevent_destroy             = false
  key_rotation_period         = "2592000s"
  service_name                = "hello-world"
  location                    = "us-central1"
  region                      = "us-central1"
  image                       = "us-docker.pkg.dev/cloudrun/container/hello"
  cloud_run_sa                = var.cloud_run_sa
  policy_for                  = var.policy_for
  folder_id                   = var.folder_id
  organization_id             = var.organization_id
  resource_names_suffix       = var.resource_names_suffix
  create_subnet               = true
  create_cloud_armor_policies = var.create_cloud_armor_policies
  cloud_armor_policies_name   = var.cloud_armor_policies_name
  groups                      = var.groups

  # If you are going to use secrets as volume uncomment this part of the code and fill with your values.
  # Also, to use secrets from another project you will need to create a VPC directional rule or add the project to the peremiter.
  # volumes = [
  #   {
  #     name = "VOLUME_NAME",
  #     secret = [
  #       {
  #         secret_name = "SECRET_NAME",
  #         items       = { key = "SECRET_VERSION", "path" = "projects/PROJECT_NUMBER/secrets/" }
  #       }
  #     ]
  #   }
  # ]

  ssl_certificates = {
    generate_certificates_for_domains = var.domain
    ssl_certificates_self_links       = []
  }
}
