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
  folder_required_roles = [
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectDeleter"
  ]

  org_required_roles = [
    "roles/accesscontextmanager.policyAdmin",
    "roles/orgpolicy.policyAdmin"
  ]

  per_module_roles = {
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

resource "google_service_account" "int_test" {
  for_each = module.project

  project      = each.value.project_id
  account_id   = "ci-account"
  display_name = "ci-account"
}

// TODO: reenable somehow if needed
///resource "google_organization_iam_member" "org_member" {
///  count = length(local.org_required_roles)
///
///  org_id = var.org_id
///  role   = local.org_required_roles[count.index]
///  member = "serviceAccount:${google_service_account.int_test.email}"
///}
///
///resource "google_folder_iam_member" "folder_member" {
///  count = length(local.folder_required_roles)
///
///  folder = "folders/${var.folder_id}"
///  role   = local.folder_required_roles[count.index]
///  member = "serviceAccount:${google_service_account.int_test.email}"
///}

resource "google_project_iam_member" "int_test" {
  // For each pair (moduleName, role), make a map entry from
  //   "moduleName.role" => {key, serviceAccount, role}
  // to apply below. Structure from https://discuss.hashicorp.com/t/foreach-loop-with-nested-list/54610.
  for_each = {
    for combination in flatten([
      for moduleName, proj in module.project : [
        for role in local.per_module_test_roles[moduleName]: {
          key             = "${moduleName}.${role}"
          service_account = google_service_account.int_test[moduleName]
          role            = role
        }
      ]
    ]) :
    combination.key => combination
  }

  project = each.value.service_account.project
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account.email}"
}

// TODO: reenable somehow if needed
///resource "google_billing_account_iam_member" "int_billing_admin" {
///  billing_account_id = var.billing_account
///  role               = "roles/billing.user"
///  member             = "serviceAccount:${google_service_account.int_test.email}"
///}

resource "google_service_account_key" "int_test" {
  for_each = module.project

  service_account_id = google_service_account.int_test[each.key].id
}
