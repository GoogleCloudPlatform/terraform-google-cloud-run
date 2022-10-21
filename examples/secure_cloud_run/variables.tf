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

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "serverless_project_id" {
  description = "The project where cloud run is going to be deployed."
  type        = string
}

variable "cloud_run_sa" {
  description = "Service account to be used on Cloud Run."
  type        = string
}

variable "vpc_project_id" {
  description = "The project where shared vpc is."
  type        = string
}

variable "shared_vpc_name" {
  description = "Shared VPC name which is going to be re-used to create Serverless Connector."
  type        = string
}

variable "kms_project_id" {
  description = "The project where KMS will be created."
  type        = string
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type        = string
}

variable "policy_for" {
  description = "Policy Root: set one of the following values to determine where the policy is applied. Possible values: [\"project\", \"folder\", \"organization\"]."
  type        = string
  default     = "project"
}

variable "folder_id" {
  description = "The folder ID to apply the policy to."
  type        = string
  default     = ""
}

variable "organization_id" {
  description = "The organization ID to apply the policy to."
  type        = string
  default     = ""
}

variable "resource_names_suffix" {
  description = "A suffix to concat in the end of the network resources names."
  type        = string
  default     = ""
}

variable "ip_cidr_range" {
  description = "The range of internal addresses that are owned by the subnetwork and which is going to be used by VPC Connector. For example, 10.0.0.0/28 or 192.168.0.0/28. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported."
  type        = string
}

variable "create_cloud_armor_policies" {
  type        = bool
  description = "When `true` the terraform will create the Cloud Armor policies. When `false`, the user must provide his own Cloud Armor name in `cloud_armor_policies_name`."
  default     = true
}

variable "cloud_armor_policies_name" {
  type        = string
  description = "Cloud Armor policy name already created in the project. If `create_cloud_armor_policies` is `false`, this variable must be provided, If `create_cloud_armor_policies` is `true`, this variable will be ignored."
  default     = null
}
