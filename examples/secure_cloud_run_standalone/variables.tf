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

variable "billing_account" {
  description = "The ID of the billing account to associate this project with."
  type        = string
}

variable "org_id" {
  description = "The organization ID."
  type        = string
}

variable "parent_folder_id" {
  description = "The ID of a folder to host the infrastructure created in this example."
  type        = string
  default     = ""
}

variable "serverless_folder_suffix" {
  description = "The suffix to be concat in the Serverless folder name fldr-serverless-<SUFFIX>."
  type        = string
  default     = ""
}

variable "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`. This variable must be provided if `create_access_context_manager_access_policy` is set to `false`"
  type        = number
  default     = null
}

variable "create_access_context_manager_access_policy" {
  description = "Defines if Access Context Manager will be created by Terraform. If set to `false`, you must provide `access_context_manager_policy_id`. More information about Access Context Manager creation in [this documentation](https://cloud.google.com/access-context-manager/docs/create-access-level)."
  type        = bool
}

variable "access_level_members" {
  description = "The list of members who will be in the access level."
  type        = list(string)
}

variable "domain" {
  description = "Domain name to run the load balancer on."
  type        = string
}
