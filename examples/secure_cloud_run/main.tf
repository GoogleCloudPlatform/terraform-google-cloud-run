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
  cloudrun_key_name     = "cloud-run-${var.resource_names_suffix}"
  cloudrun_keyring_name = "cloud-run-keyring-${var.resource_names_suffix}"
}

module "secure_cloud_run" {
  source = "../../modules/secure-cloud-run"

  connector_name        = "con-run"
  subnet_name           = "vpc-subnet"
  vpc_project_id        = var.vpc_project_id
  serverless_project_id = var.serverless_project_id
  domain                = var.domain
  kms_project_id        = var.kms_project_id
  shared_vpc_name       = var.shared_vpc_name
  ip_cidr_range         = var.ip_cidr_range
  key_name              = local.cloudrun_key_name
  keyring_name          = local.cloudrun_keyring_name
  prevent_destroy       = false
  key_rotation_period   = "2592000s"
  service_name          = "hello-world"
  location              = "us-central1"
  region                = "us-central1"
  image                 = "us-docker.pkg.dev/cloudrun/container/hello"
  cloud_run_sa          = var.cloud_run_sa
  policy_for            = var.policy_for
  folder_id             = var.folder_id
  organization_id       = var.organization_id
  resource_names_suffix = var.resource_names_suffix
  create_subnet         = true
}
