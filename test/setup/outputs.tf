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

// project_ids_per_module is resolved to `project_id` by the tft test framework.
output "project_ids_per_module" {
  value = {
    for module_name, v in module.project : module_name => v.project_id
  }
}

// `sa_emails_per_module` is resolved to `sa_email` by the tft test framework.
output "sa_emails_per_module" {
  value = {
    for module_name, v in google_service_account_key.int_test : module_name => v.email
  }
  sensitive = true
}

// `sa_keys_per_module` is resolved to `sa_key` by the tft test framework.
output "sa_keys_per_module" {
  value = {
    for module_name, v in google_service_account_key.int_test : module_name => v.private_key
  }
  sensitive = true
}

output "verified_domain_name" {
  value = []
}

output "cloud_run_deletion_protection" {
  description = "This field prevents Terraform from destroying or recreating the Cloud Run Jobs and Services. Set to `false` in integration tests."
  value       = false
}
