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
  location        = "us-west1"
  region          = "us-west1"
  repository_name = "rep-secure-cloud-run"

  hello_image = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}

resource "random_id" "random_folder_suffix" {
  byte_length = 2
}

module "secure_harness" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/secure-serverless-harness"
  version = "~> 0.13"

  billing_account                             = var.billing_account
  security_project_name                       = "prj-kms-secure-cloud-run"
  serverless_project_names                    = ["prj-secure-cloud-run"]
  org_id                                      = var.org_id
  parent_folder_id                            = var.parent_folder_id
  serverless_folder_suffix                    = random_id.random_folder_suffix.hex
  region                                      = local.region
  location                                    = local.location
  vpc_name                                    = "vpc-secure-cloud-run"
  subnet_ip                                   = "10.0.0.0/28"
  private_service_connect_ip                  = "10.3.0.5"
  create_access_context_manager_access_policy = var.create_access_context_manager_access_policy
  access_context_manager_policy_id            = var.access_context_manager_policy_id
  access_level_members                        = var.access_level_members
  key_name                                    = "key-secure-artifact-registry"
  keyring_name                                = "krg-secure-artifact-registry"
  prevent_destroy                             = false
  artifact_registry_repository_name           = local.repository_name
  egress_policies                             = var.egress_policies
  ingress_policies                            = var.ingress_policies
  base_serverless_api                         = "run.googleapis.com"
}

resource "null_resource" "copy_image" {
  provisioner "local-exec" {
    command = "gcloud container images add-tag ${local.hello_image} ${local.location}-docker.pkg.dev/${module.secure_harness.security_project_id}/${local.repository_name}/hello:latest -q"
  }

  depends_on = [
    module.secure_harness
  ]
}

module "secure_cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-run"
  version = "~> 0.13"

  location                                = local.location
  region                                  = local.region
  serverless_project_id                   = module.secure_harness.serverless_project_ids[0]
  vpc_project_id                          = module.secure_harness.network_project_id[0]
  kms_project_id                          = module.secure_harness.security_project_id
  key_name                                = "key-secure-cloud-run"
  keyring_name                            = "krg-secure-cloud-run"
  service_name                            = "srv-secure-cloud-run"
  image                                   = "${local.location}-docker.pkg.dev/${module.secure_harness.security_project_id}/${module.secure_harness.artifact_registry_repository_name}/hello:latest"
  cloud_run_sa                            = module.secure_harness.service_account_email[module.secure_harness.serverless_project_ids[0]]
  connector_name                          = "con-secure-cloud-run"
  subnet_name                             = module.secure_harness.service_subnet[0]
  create_subnet                           = false
  shared_vpc_name                         = module.secure_harness.service_vpc[0].network_name
  ip_cidr_range                           = "10.0.0.0/28"
  prevent_destroy                         = false
  artifact_registry_repository_location   = local.location
  artifact_registry_repository_project_id = module.secure_harness.security_project_id
  artifact_registry_repository_name       = local.repository_name
  env_vars                                = [{ name = "TEST", value = "true" }]
  ssl_certificates = {
    generate_certificates_for_domains = var.domain
    ssl_certificates_self_links       = []
  }

  depends_on = [
    null_resource.copy_image
  ]
}
