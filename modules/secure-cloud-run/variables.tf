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

variable "location" {
  description = "The location where resources are going to be deployed."
  type        = string
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources."
  type        = string
}

variable "serverless_project_id" {
  description = "The project to deploy the cloud run service."
  type        = string
}

variable "vpc_project_id" {
  description = "The host project for the shared vpc."
  type        = string
}

variable "key_name" {
  description = "The name of KMS Key to be created and used in Cloud Run."
  type        = string
  default     = "cloud-run-kms-key"
}

variable "kms_project_id" {
  description = "The project where KMS will be created."
  type        = string
}

variable "service_name" {
  description = "Shared VPC name."
  type        = string
}

variable "image" {
  description = "Image url to be deployed on Cloud Run."
  type        = string
}

variable "cloud_run_sa" {
  description = "Service account to be used on Cloud Run."
  type        = string
}

variable "connector_name" {
  description = "The name for the connector to be created."
  type        = string
  default     = "serverless-vpc-connector"
}

variable "subnet_name" {
  description = "Subnet name to be re-used to create Serverless Connector."
  type        = string
  default     = null
}

variable "shared_vpc_name" {
  description = "Shared VPC name which is going to be re-used to create Serverless Connector."
  type        = string
}

variable "env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables (cleartext)"
  default     = []
}

variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users."
  default     = []
}

variable "prevent_destroy" {
  description = "Set the `prevent_destroy` lifecycle attribute on the Cloud KMS key."
  type        = bool
  default     = true
}

variable "keyring_name" {
  description = "Keyring name."
  type        = string
  default     = "cloud-run-kms-keyring"
}

variable "key_rotation_period" {
  description = "Period of key rotation in seconds."
  type        = string
  default     = "2592000s"
}

variable "key_protection_level" {
  description = "The protection level to use when creating a version based on this template. Possible values: [\"SOFTWARE\", \"HSM\"]"
  type        = string
  default     = "HSM"
}

variable "ip_cidr_range" {
  description = "The range of internal addresses that are owned by the subnetwork and which is going to be used by VPC Connector. For example, 10.0.0.0/28 or 192.168.0.0/28. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported."
  type        = string
}

variable "artifact_registry_repository_project_id" {
  description = "Artifact Registry Repository Project ID to grant serverless identity viewer role."
  type        = string
  default     = null
}

variable "artifact_registry_repository_location" {
  description = "Artifact Registry Repository location to grant serverless identity viewer role."
  type        = string
  default     = null
}

variable "artifact_registry_repository_name" {
  description = "Artifact Registry Repository name to grant serverless identity viewer role"
  type        = string
  default     = null
}

variable "grant_artifact_register_reader" {
  description = "When true it will grant permission to read an image from your artifact registry. When true, you must provide `artifact_registry_repository_project_id`, `artifact_registry_repository_location` and `artifact_registry_repository_name`."
  type        = bool
  default     = false
}

variable "create_subnet" {
  description = "The subnet will be created with the subnet_name variable if true. When false, it will use the subnet_name for the subnet."
  type        = bool
  default     = true
}

variable "domain" {
  description = "Domain name to run the load balancer on."
  type        = list(string)
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
  description = "A suffix to concat in the end of the network resources names being created."
  type        = string
  default     = null
}

variable "max_scale_instances" {
  description = "Sets the maximum number of container instances needed to handle all incoming requests or events from each revison from Cloud Run. For more information, access this [documentation](https://cloud.google.com/run/docs/about-instance-autoscaling)."
  type        = number
  default     = 2
}

variable "min_scale_instances" {
  description = "Sets the minimum number of container instances needed to handle all incoming requests or events from each revison from Cloud Run. For more information, access this [documentation](https://cloud.google.com/run/docs/about-instance-autoscaling)."
  type        = number
  default     = 1
}

variable "vpc_egress_value" {
  description = "Sets VPC Egress firewall rule. Supported values are all-traffic, all (deprecated), and private-ranges-only. all-traffic and all provide the same functionality. all is deprecated but will continue to be supported. Prefer all-traffic."
  type        = string
  default     = "private-ranges-only"
}

variable "create_cloud_armor_policies" {
  type        = bool
  description = "When `true`, the terraform will create the Cloud Armor policies. When `false`, the user must provide their own Cloud Armor name in `cloud_armor_policies_name`."
  default     = true
}

variable "cloud_armor_policies_name" {
  type        = string
  description = "Cloud Armor policy name already created in the project. If `create_cloud_armor_policies` is `false`, this variable must be provided, If `create_cloud_armor_policies` is `true`, this variable will be ignored."
  default     = null
}

variable "verified_domain_name" {
  type        = list(string)
  description = "List of Custom Domain Name"
  default     = []
}

variable "volumes" {
  description = "[Beta] Volumes needed for environment variables (when using secret)."
  type = list(object({
    name = string
    secret = set(object({
      secret_name = string
      items       = map(string)
    }))
  }))
  default = []
}

variable "group_serverless_administrator" {
  description = "The Serverless Administrators email group."
  type        = string
  default     = ""
}

variable "group_serverless_security_administrator" {
  description = "The Serverless Security Administrators email group."
  type        = string
  default     = ""
}

variable "group_cloud_run_developer" {
  description = "The Cloud Run Developer email group."
  type        = string
  default     = ""
}

variable "group_cloud_run_user" {
  description = "The Cloud Run User email group."
  type        = string
  default     = ""
}
