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

module "cloud_run_kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 3.0"

  project_id           = var.kms_project_id
  location             = var.location
  keyring              = var.keyring_name
  keys                 = [var.key_name]
  set_decrypters_for   = length(var.decrypters) > 0 ? [var.key_name] : []
  set_encrypters_for   = length(var.encrypters) > 0 ? [var.key_name] : []
  decrypters           = var.decrypters
  encrypters           = var.encrypters
  set_owners_for       = length(var.owners) > 0 ? [var.key_name] : []
  owners               = var.owners
  prevent_destroy      = var.prevent_destroy
  key_rotation_period  = var.key_rotation_period
  key_protection_level = var.key_protection_level
}
