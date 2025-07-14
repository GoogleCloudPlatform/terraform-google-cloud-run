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
      "serviceusage.googleapis.com",
      "iam.googleapis.com",
      "cloudbilling.googleapis.com",
      "accesscontextmanager.googleapis.com"
    ],
    job-exec = [
      "run.googleapis.com",
    ],
    secure-cloud-run = [
      "compute.googleapis.com",
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com"
    ],
    secure-cloud-run-core = [
      "compute.googleapis.com",
      "run.googleapis.com"
    ],
    secure-cloud-run-security = [
      "run.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com"
    ],
    secure-serverless-harness = [
      "artifactregistry.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "run.googleapis.com",
      "serviceusage.googleapis.com"
    ],
    secure-serverless-net = [
      "run.googleapis.com",
      "compute.googleapis.com",
      "servicenetworking.googleapis.com",
      "accesscontextmanager.googleapis.com"
    ],
    service-project-factory = [
      "cloudresourcemanager.googleapis.com",
      "serviceusage.googleapis.com",
      "cloudbilling.googleapis.com",
      "compute.googleapis.com"
    ],
    v2 = [
      "run.googleapis.com",
      "iam.googleapis.com",
      "serviceusage.googleapis.com",
    ],
  }
}

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"

  name                    = "ci-cloud-run"
  random_project_id       = "true"
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  default_service_account = "keep"
  deletion_policy         = "DELETE"

  activate_apis = concat([
  ], flatten(values(local.per_module_services)))
}
