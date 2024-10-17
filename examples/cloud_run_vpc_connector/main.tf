/**
 * Copyright 2021 Google LLC
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

module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.2"
  project_id = var.project_id
  prefix     = "sa-cloud-run"
  names      = ["vpc-connector"]
}

module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.13"

  service_name          = "ci-cloud-run-sc"
  project_id            = var.project_id
  location              = "us-central1"
  image                 = "us-docker.pkg.dev/cloudrun/container/hello"
  service_account_email = module.service_account.email

  template_annotations = {
    "autoscaling.knative.dev/maxScale"        = 4
    "autoscaling.knative.dev/minScale"        = 2
    "run.googleapis.com/vpc-access-connector" = element(tolist(module.serverless_connector.connector_ids), 1)
    "run.googleapis.com/vpc-access-egress"    = "all-traffic"
  }
}
