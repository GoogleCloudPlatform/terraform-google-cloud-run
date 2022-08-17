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

variable "vpc_project_id" {
  description = "The project where shared vpc is."
  type        = string
}

variable "serverless_project_id" {
  description = "The project where cloud run is going to be deployed."
  type        = string
}

variable "connector_name" {
  description = "The name of the serverless connector which is going to be created."
  type        = string
}

variable "subnet_name" {
  description = "Subnet name to be re-used to create Serverless Connector."
  type        = string
}

variable "shared_vpc_name" {
  description = "Shared VPC name which is going to be used to create Serverless Connector."
  type        = string
}

variable "connector_on_host_project" {
  description = "Connector is going to be created on the host project if true. When false, connector is going to be created on service project. For more information, access [documentation](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc)."
  type        = bool
  default     = false
}

variable "ip_cidr_range" {
  description = "The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, 10.0.0.0/8 or 192.168.0.0/16. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported"
  type        = string
}

variable "create_subnet" {
  description = "The subnet will be created with the subnet_name variable if true. When false, it will use the subnet_name for the subnet."
  type        = bool
  default     = true
}

variable "flow_sampling" {
  description = "Sampling rate of VPC flow logs. The value must be in [0,1]. Where 1.0 means all logs, 0.5 mean half of the logs and 0.0 means no logs are reported."
  type        = number
  default     = 1.0
}
