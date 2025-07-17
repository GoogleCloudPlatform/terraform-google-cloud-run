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
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    job-exec = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    secure-cloud-run = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    secure-cloud-run-core = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    secure-cloud-run-security = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    secure-serverless-harness = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    secure-serverless-net = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    service-project-factory = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/artifactregistry.admin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/cloudkms.admin",
      "roles/resourcemanager.projectIamAdmin"
    ],
    v2 = [
      "roles/run.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/serviceusage.serviceUsageViewer",
      "roles/resourcemanager.projectIamAdmin",
      "roles/compute.viewer",
      "roles/iap.admin"
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
