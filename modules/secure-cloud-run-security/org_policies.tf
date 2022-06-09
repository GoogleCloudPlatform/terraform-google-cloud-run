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

module "cloudrun_allowed_ingress" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 5.1"

  constraint        = "constraints/run.allowedIngress"
  policy_for        = "project"
  project_id        = var.serverless_project_id
  policy_type       = "list"
  allow             = ["is:internal-and-cloud-load-balancing"]
  allow_list_length = 1
}

module "cloudrun_allowed_vpc_egress" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 5.1"

  policy_for        = "project"
  project_id        = var.serverless_project_id
  constraint        = "constraints/run.allowedVPCEgress"
  policy_type       = "list"
  allow             = ["private-ranges-only"]
  allow_list_length = 1
}
