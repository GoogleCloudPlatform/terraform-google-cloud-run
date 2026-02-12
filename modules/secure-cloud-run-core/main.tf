/**
 * Copyright 2024 Google LLC
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
  env_vars_map = { for item in var.env_vars : item.name => item.value }

  main_container = {
    container_name    = var.service_name
    container_image   = var.image
    container_command = var.container_command
    container_args    = var.argument
    working_dir       = null

    ports = {
      name           = var.ports.name
      container_port = var.ports.port
    }

    resources = {
      limits            = var.limits
      cpu_idle          = true
      startup_cpu_boost = false
    }

    env_vars        = local.env_vars_map
    env_secret_vars = {}

    startup_probe  = var.startup_probe
    liveness_probe = var.liveness_probe

    depends_on_container = []
    volume_mounts        = var.volume_mounts
  }

  traffic_config = [
    for t in var.traffic_split : {
      percent  = t.percent
      type     = null
      revision = lookup(t, "latest_revision", true) ? null : lookup(t, "revision_name", null)
      tag      = lookup(t, "tag", null)
    }
  ]

  volumes_config = [
    for v in var.volumes : {
      name = v.name

      secret = length(v.secret) > 0 ? {
        secret       = v.secret[0].secret
        default_mode = try(tostring(v.secret[0].default_mode), null)
        items = length(try(v.secret[0].items, [])) > 0 ? {
          path    = v.secret[0].items[0].path
          version = v.secret[0].items[0].version
          mode    = try(tostring(v.secret[0].items[0].mode), null)
        } : null
      } : null

      cloud_sql_instance = length(v.cloud_sql_instance) > 0 ? {
        instances = v.cloud_sql_instance[0].instances
      } : null

      gcs = length(v.gcs) > 0 ? {
        bucket    = v.gcs[0].bucket
        read_only = try(tostring(v.gcs[0].read_only), null)
      } : null

      nfs = length(v.nfs) > 0 ? {
        server    = v.nfs[0].server
        path      = v.nfs[0].path
        read_only = try(tostring(v.nfs[0].read_only), null)
      } : null

      empty_dir = length(v.empty_dir) > 0 ? {
        medium     = v.empty_dir[0].medium
        size_limit = v.empty_dir[0].size_limit
      } : null
    }
  ]

  secrets_list = distinct(flatten([
    for v in var.volumes : [
      for s in v.secret : [
        for item in(s.items != null ? s.items : []) : {
          name        = v.name
          secret_name = s.secret
          path        = item.path
        }
      ]
    ]
  ]))

  vpc_config = var.vpc_connector_id != null ? {
    connector          = var.vpc_connector_id
    egress             = var.vpc_egress_value
    network_interfaces = null
    } : (var.vpc_network_interface != null ? {
      connector          = null
      egress             = var.vpc_egress_value
      network_interfaces = var.vpc_network_interface
  } : null)
}

module "cloud_run" {
  source = "../v2"

  project_id   = var.project_id
  service_name = var.service_name
  location     = var.location
  description  = "Managed by Terraform"

  service_account        = var.cloud_run_sa
  create_service_account = false

  containers = [local.main_container]

  revision = var.generate_revision_name ? null : "${var.service_name}-rev"

  template_scaling = {
    min_instance_count = var.min_scale_instances
    max_instance_count = var.max_scale_instances
  }

  vpc_access = local.vpc_config

  ingress               = var.ingress
  execution_environment = var.execution_environment

  volumes        = local.volumes_config
  encryption_key = var.encryption_key

  service_labels       = var.service_labels
  template_labels      = var.template_labels
  service_annotations  = {}
  template_annotations = {}

  timeout                          = "${var.timeout_seconds}s"
  max_instance_request_concurrency = var.container_concurrency != null ? tostring(var.container_concurrency) : null

  traffic = local.traffic_config

  members                       = var.members
  iap_members                   = var.iap_members
  launch_stage                  = var.launch_stage
  node_selector                 = var.node_selector
  gpu_zonal_redundancy_disabled = var.gpu_zonal_redundancy_disabled
  enable_prometheus_sidecar     = var.enable_prometheus_sidecar
  cloud_run_deletion_protection = var.cloud_run_deletion_protection

  force_override         = var.force_override
  certificate_mode       = var.certificate_mode
  domain_map_labels      = var.domain_map_labels
  domain_map_annotations = var.domain_map_annotations
  verified_domain_name   = var.verified_domain_name

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
  for_each  = { for s in local.secrets_list : "${s.name}-${s.path}" => s }
  secret_id = each.value.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloud_run_sa}"
}

resource "google_cloud_run_domain_mapping" "domain_map" {
  for_each = toset(var.verified_domain_name)
  provider = google-beta
  location = var.location
  name     = each.value
  project  = var.project_id

  metadata {
    labels      = var.domain_map_labels
    annotations = var.domain_map_annotations
    namespace   = var.project_id
  }

  spec {
    route_name       = module.cloud_run.service_name
    force_override   = var.force_override
    certificate_mode = var.certificate_mode
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["run.googleapis.com/operation-id"],
    ]
  }
}
