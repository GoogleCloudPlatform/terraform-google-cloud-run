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

locals {
  ip_range = "10.35.${random_integer.ip_random_1.result}.0/28"
}

resource "random_integer" "ip_random_1" {
  min = 0
  max = 9
}


module "secure_cloud_run" {
  source                = "../../../examples/secure_cloud_run"
  shared_vpc_name       = data.terraform_remote_state.sfb-network-prod.outputs.restricted_network_name
  vpc_project_id        = data.terraform_remote_state.sfb-network-prod.outputs.restricted_host_project_id
  cloud_run_sa          = module.serverless_project.service_account_email
  kms_project_id        = module.kms_project.project_id
  serverless_project_id = module.serverless_project.project_id
  domain                = var.domain
  resource_names_suffix = var.resource_names_suffix
  ip_cidr_range         = local.ip_range

  depends_on = [
    module.kms_project,
    module.serverless_project
  ]
}
