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

variable "serverless_type" {
  description = "The type of resource to be used. It supports only CLOUD_RUN or CLOUD_FUNCTION"
  type        = string
}

variable "security_project_name" {
  description = "The name to give the security project."
  type        = string
}

variable "network_project_name" {
  description = "The name to give the shared vpc project."
  type        = string
  default     = ""
}

variable "serverless_project_names" {
  description = "The name to give the Cloud Serverless project."
  type        = list(string)
}

variable "org_id" {
  description = "The organization ID."
  type        = string
}

variable "serverless_folder_suffix" {
  description = "The suffix to be concat in the Serverless folder name fldr-serverless-<SUFFIX>."
  type        = string
  default     = ""
}

variable "parent_folder_id" {
  description = "The ID of a folder to host the infrastructure created in this module."
  type        = string
  default     = ""
}

variable "access_context_manager_policy_id" {
  type        = number
  description = "The ID of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
  default     = null
}

variable "create_access_context_manager_access_policy" {
  description = "Defines if Access Context Manager will be created by Terraform."
  type        = bool
  default     = false
}

variable "use_shared_vpc" {
  description = "Defines if the network created will be a single or shared vpc."
  type        = bool
  default     = false
}

variable "access_level_members" {
  description = "The list of additional members who will be in the access level."
  type        = list(string)
}

variable "egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference), each list object has a `from` and `to` value that describes egress_from and egress_to.\n\nExample: `[{ from={ identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "region" {
  description = "The region in which the subnetwork will be created."
  type        = string
}

variable "vpc_name" {
  description = "The name of the network."
  type        = string
}

variable "subnet_ip" {
  description = "The CDIR IP range of the subnetwork."
  type        = string
}

variable "private_service_connect_ip" {
  description = "The internal IP to be used for the private service connect."
  type        = string
}

variable "service_account_project_roles" {
  type        = map(list(string))
  description = "Common roles to apply to the Cloud Serverless service account in the serverless project."
  default     = {}
}

variable "artifact_registry_repository_name" {
  description = "The name of the Artifact Registry Repository to be created."
  type        = string
}

variable "artifact_registry_repository_description" {
  description = "The description of the Artifact Registry Repository to be created."
  type        = string
  default     = "Secure Cloud Run Artifact Registry Repository"
}

variable "artifact_registry_repository_format" {
  description = "The format of the Artifact Registry Repository to be created."
  type        = string
  default     = "DOCKER"
}

variable "keyring_name" {
  description = "Keyring name."
  type        = string
}

variable "key_rotation_period" {
  description = "Period of key rotation in seconds. Default value is equivalent to 30 days."
  type        = string
  default     = "2592000s"
}

variable "key_name" {
  description = "Key name."
  type        = string
}

variable "key_protection_level" {
  description = "The protection level to use when creating a version based on this template. Possible values: [\"SOFTWARE\", \"HSM\"]."
  type        = string
  default     = "HSM"
}

variable "location" {
  description = "The location where resources are going to be deployed."
  type        = string
}

variable "owners" {
  description = "List of comma-separated owners for each key declared in set_owners_for."
  type        = list(string)
  default     = []
}

variable "encrypters" {
  description = "List of comma-separated owners for each key declared in set_encrypters_for."
  type        = list(string)
  default     = []
}

variable "decrypters" {
  description = "List of comma-separated owners for each key declared in set_decrypters_for."
  type        = list(string)
  default     = []
}

variable "prevent_destroy" {
  description = "Set the prevent_destroy lifecycle attribute on keys."
  type        = bool
  default     = true
}

variable "dns_enable_inbound_forwarding" {
  type        = bool
  description = "Toggle inbound query forwarding for VPC DNS."
  default     = true
}

variable "dns_enable_logging" {
  type        = bool
  description = "Toggle DNS logging for VPC DNS."
  default     = true
}
