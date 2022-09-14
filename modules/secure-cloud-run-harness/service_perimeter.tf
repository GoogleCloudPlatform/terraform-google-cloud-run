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
  prefix                           = "secure_cloud_run"
  access_level_name                = "alp_${local.prefix}_members_${random_id.random_access_level_suffix.hex}"
  perimeter_name                   = "sp_${local.prefix}_perimeter_${random_id.random_access_level_suffix.hex}"
  access_context_manager_policy_id = var.create_access_context_manager_access_policy ? google_access_context_manager_access_policy.access_policy[0].id : var.access_context_manager_policy_id

}

resource "random_id" "random_access_level_suffix" {
  byte_length = 2
}

/******************************************
  Access Context Manager Policy
*******************************************/

resource "google_access_context_manager_access_policy" "access_policy" {
  count  = var.create_access_context_manager_access_policy ? 1 : 0
  parent = "organizations/${var.org_id}"
  title  = "default policy"
}

module "access_level_members" {
  source      = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version     = "~> 4.0"
  description = "${local.prefix} Access Level"
  policy      = local.access_context_manager_policy_id
  name        = local.access_level_name
  members     = var.access_level_additional_members
}

module "regular_service_perimeter" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version        = "~> 4.0"
  policy         = local.access_context_manager_policy_id
  perimeter_name = local.perimeter_name
  description    = "Serverless VPC Service Controls perimeter"

  restricted_services = distinct(concat([
    "cloudkms.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "containerregistry.googleapis.com",
    "containeranalysis.googleapis.com",
    "binaryauthorization.googleapis.com"
  ], var.additional_restricted_services))


  access_levels = [module.access_level_members.name]

  egress_policies  = var.egress_policies
  ingress_policies = var.ingress_policies

  depends_on = [
    google_artifact_registry_repository_iam_member.member,
    module.artifact_registry_kms,
    module.network,
    module.private_service_connect,
    google_project_iam_member.cloud_run_sa_roles
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_serverless_resource" {
  perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${module.regular_service_perimeter.perimeter_name}"
  resource       = "projects/${module.serverless_project.project_number}"
}

resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_security_resource" {
  perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${module.regular_service_perimeter.perimeter_name}"
  resource       = "projects/${module.security_project.project_number}"
}
