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

  extra_roles_for_tests = {
    root = [
      // For "examples/cloud_run_vpc_connector".
      "roles/iam.networkAdmin",
      "roles/vpcaccess.admin",
    ],
    job-exec = [
      "roles/compute.viewer",
    ]
  }

  // A list of items like:
  // { module_name = "x", role = "role1"}
  // { module_name = "x", role = "role2"}
  // { module_name = "y", role = "role3"}
  module_role_combinations = flatten(
    [for module_name, _ in module.project :
      [for role in setunion(local.per_module_roles[module_name], lookup(local.extra_roles_for_tests, module_name, [])): {
          module_name = module_name
          role        = role
        }
      ]
    ]
  )
}

resource "google_service_account" "int_test" {
  for_each = module.project

  project      = each.value.project_id
  account_id   = "ci-account"
  display_name = "ci-account"
}

resource "google_project_iam_member" "int_test" {
  for_each = {
    for combination in local.module_role_combinations :
      "${combination.module_name}.${combination.role}" => {
        service_account = google_service_account.int_test[combination.module_name]
        role            = combination.role
      }
  }

  project = each.value.service_account.project
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account.email}"
}

resource "google_service_account_key" "int_test" {
  for_each = module.project

  service_account_id = google_service_account.int_test[each.key].id
}
