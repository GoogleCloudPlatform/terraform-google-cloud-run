/**
 * Copyright 2019 Google LLC
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
  per_module_services = {
    root = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    job-exec = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    secure-cloud-run = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    secure-cloud-run-core = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    secure-cloud-run-security = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    secure-serverless-harness = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    secure-serverless-net = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    service-project-factory = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
    v2 = [
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "iam.googleapis.com",
      "monitoring.googleapis.com",
      "compute.googleapis.com",
      "iap.googleapis.com"
    ],
  }
  extra_services_for_tests = {
    root = [
      // For "examples/cloud_run_vpc_connector".
      "vpcaccess.googleapis.com",
    ],
  }
  per_module_test_services = {
    for module, services in local.per_module_services:
    module => setunion(services, lookup(local.extra_services_for_tests, module, []))
  }
}

module "project" {
  for_each = local.per_module_test_services

  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"

  name                     = "ci-cloud-run"
  random_project_id        = "true"
  random_project_id_length = 8
  org_id                   = var.org_id
  folder_id                = var.folder_id
  billing_account          = var.billing_account
  default_service_account  = "keep"
  deletion_policy          = "DELETE"

  activate_apis = each.value
}
