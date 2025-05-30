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
  annotations_for_template = {
    "autoscaling.knative.dev/maxScale"        = var.max_scale_instances,
    "autoscaling.knative.dev/minScale"        = var.min_scale_instances,
    "run.googleapis.com/vpc-access-connector" = var.vpc_connector_id,
    "run.googleapis.com/vpc-access-egress"    = var.vpc_egress_value,
    "run.googleapis.com/network-interfaces"   = var.network_interfaces
    "run.googleapis.com/cpu-throttling"       = var.cpu_throttling
    "run.googleapis.com/startup-cpu-boost"    = var.cpu_boost
  }

  conditional_annotations = {
    secret = {}
  }

  secrets = distinct(flatten([
    for secret in var.volumes : [
      for secret_name in secret.secret : [
        {
          "name" : secret.name,
          "secret_name" : secret_name.secret_name,
          "path" : secret_name.items.path
        }
      ]
    ]
  ]))

  secrets_alias = [
    for secret in local.secrets :
    "${secret.name}:${secret.path}"
  ]

}

module "cloud_run" {
  source = "../.."

  service_name           = var.service_name
  project_id             = var.project_id
  location               = var.location
  image                  = var.image
  service_account_email  = var.cloud_run_sa
  encryption_key         = var.encryption_key
  members                = var.members
  env_vars               = var.env_vars
  env_secret_vars        = var.env_secret_vars
  generate_revision_name = var.generate_revision_name
  traffic_split          = var.traffic_split
  service_labels         = var.service_labels
  template_labels        = var.template_labels
  container_concurrency  = var.container_concurrency
  timeout_seconds        = var.timeout_seconds
  volumes                = var.volumes
  limits                 = var.limits
  requests               = var.requests
  ports                  = var.ports
  argument               = var.argument
  container_command      = var.container_command
  volume_mounts          = var.volume_mounts
  force_override         = var.force_override
  certificate_mode       = var.certificate_mode
  domain_map_labels      = var.domain_map_labels
  domain_map_annotations = var.domain_map_annotations
  verified_domain_name   = var.verified_domain_name

  service_annotations = {
    "run.googleapis.com/ingress" = var.ingress
  }

  template_annotations = merge(
    local.annotations_for_template,
    local.conditional_annotations["secret"]
  )

  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

resource "google_project_service_identity" "serverless_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "run.googleapis.com"
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"

  depends_on = [
    google_secret_manager_secret_iam_member.member
  ]
}

resource "google_secret_manager_secret_iam_member" "member" {
  for_each  = { for secret in local.secrets : secret.name => secret }
  secret_id = each.value.path
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloud_run_sa}"
}
