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
  prefix                           = "secure_cloud_run"
  access_level_name                = "alp_${local.prefix}_members_${random_string.random_access_level_suffix.result}"
  perimeter_name                   = "sp_${local.prefix}_perimeter_${random_string.random_access_level_suffix.result}"
  access_context_manager_policy_id = var.create_access_context_manager_access_policy ? google_access_context_manager_access_policy.access_policy[0].id : var.access_context_manager_policy_id
  access_level_members = concat(var.access_level_members,
    [for project in module.serverless_project : "serviceAccount:${project.services_identities["cloudbuild"]}"],
    [for project in module.serverless_project : "serviceAccount:${project.services_identities["gcs"]}"],
    [for project in module.serverless_project : "serviceAccount:${project.services_identities["cloudservices"]}"]
  )
}

resource "random_string" "random_access_level_suffix" {
  length  = 4
  lower   = true
  numeric = true
  upper   = false
  special = false
}

/******************************************
  Access Context Manager Policy
*******************************************/

resource "google_access_context_manager_access_policy" "access_policy" {
  count  = var.create_access_context_manager_access_policy ? 1 : 0
  parent = "organizations/${var.org_id}"
  title  = "default policy"
}

module "access_level_members" {
  source      = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version     = "~> 5.0"
  description = "${local.prefix} Access Level"
  policy      = local.access_context_manager_policy_id
  name        = local.access_level_name
  members     = local.access_level_members
}

module "regular_service_perimeter" {
  source                  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version                 = "~> 5.0"
  policy                  = local.access_context_manager_policy_id
  perimeter_name          = local.perimeter_name
  description             = "Serverless VPC Service Controls perimeter"
  access_levels           = [module.access_level_members.name]
  egress_policies         = var.egress_policies
  ingress_policies        = var.ingress_policies
  vpc_accessible_services = ["RESTRICTED-SERVICES"]

  restricted_services = [
    "accessapproval.googleapis.com",
    "adsdatahub.googleapis.com",
    "aiplatform.googleapis.com",
    "alloydb.googleapis.com",
    "alpha-documentai.googleapis.com",
    "analyticshub.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "artifactregistry.googleapis.com",
    "assuredworkloads.googleapis.com",
    "automl.googleapis.com",
    "baremetalsolution.googleapis.com",
    "batch.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigtable.googleapis.com",
    "binaryauthorization.googleapis.com",
    "cloud.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddebugger.googleapis.com",
    "clouddeploy.googleapis.com",
    "clouderrorreporting.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudprofiler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudsearch.googleapis.com",
    "cloudtrace.googleapis.com",
    "composer.googleapis.com",
    "compute.googleapis.com",
    "connectgateway.googleapis.com",
    "contactcenterinsights.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerfilesystem.googleapis.com",
    "containerregistry.googleapis.com",
    "containerthreatdetection.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "datafusion.googleapis.com",
    "datamigration.googleapis.com",
    "dataplex.googleapis.com",
    "dataproc.googleapis.com",
    "datastream.googleapis.com",
    "dialogflow.googleapis.com",
    "dlp.googleapis.com",
    "dns.googleapis.com",
    "documentai.googleapis.com",
    "domains.googleapis.com",
    "eventarc.googleapis.com",
    "file.googleapis.com",
    "firebaseappcheck.googleapis.com",
    "firebaserules.googleapis.com",
    "firestore.googleapis.com",
    "gameservices.googleapis.com",
    "gkebackup.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "healthcare.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "iaptunnel.googleapis.com",
    "ids.googleapis.com",
    "integrations.googleapis.com",
    "kmsinventory.googleapis.com",
    "krmapihosting.googleapis.com",
    "language.googleapis.com",
    "lifesciences.googleapis.com",
    "logging.googleapis.com",
    "managedidentities.googleapis.com",
    "memcache.googleapis.com",
    "meshca.googleapis.com",
    "meshconfig.googleapis.com",
    "metastore.googleapis.com",
    "ml.googleapis.com",
    "monitoring.googleapis.com",
    "networkconnectivity.googleapis.com",
    "networkmanagement.googleapis.com",
    "networksecurity.googleapis.com",
    "networkservices.googleapis.com",
    "notebooks.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "orgpolicy.googleapis.com",
    "osconfig.googleapis.com",
    "oslogin.googleapis.com",
    "privateca.googleapis.com",
    "pubsub.googleapis.com",
    "pubsublite.googleapis.com",
    "recaptchaenterprise.googleapis.com",
    "recommender.googleapis.com",
    "redis.googleapis.com",
    "retail.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicedirectory.googleapis.com",
    "spanner.googleapis.com",
    "speakerid.googleapis.com",
    "speech.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "storagetransfer.googleapis.com",
    "sts.googleapis.com",
    "texttospeech.googleapis.com",
    "timeseriesinsights.googleapis.com",
    "tpu.googleapis.com",
    "trafficdirector.googleapis.com",
    "transcoder.googleapis.com",
    "translate.googleapis.com",
    "videointelligence.googleapis.com",
    "vision.googleapis.com",
    "visionai.googleapis.com",
    "vmmigration.googleapis.com",
    "vpcaccess.googleapis.com",
    "webrisk.googleapis.com",
    "workflows.googleapis.com",
    "workstations.googleapis.com",
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_serverless_resource" {
  for_each       = module.serverless_project
  perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${module.regular_service_perimeter.perimeter_name}"
  resource       = "projects/${each.value.project_number}"
  depends_on = [
    module.serverless_project,
    module.security_project,
    module.network_project,
    module.regular_service_perimeter
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_security_resource" {
  perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${module.regular_service_perimeter.perimeter_name}"
  resource       = "projects/${module.security_project.project_number}"
  depends_on = [
    module.serverless_project,
    module.security_project,
    module.network_project,
    module.regular_service_perimeter
  ]
}

resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_network_resource" {
  count          = var.use_shared_vpc ? 1 : 0
  perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${module.regular_service_perimeter.perimeter_name}"
  resource       = "projects/${module.network_project[0].project_number}"
  depends_on = [
    module.serverless_project,
    module.security_project,
    module.network_project,
    module.regular_service_perimeter
  ]
}

resource "time_sleep" "wait_vpc_sc_propagation" {
  depends_on = [
    google_access_context_manager_service_perimeter_resource.service_perimeter_security_resource,
    google_access_context_manager_service_perimeter_resource.service_perimeter_serverless_resource,
    google_access_context_manager_service_perimeter_resource.service_perimeter_network_resource,
    module.access_level_members,
    module.regular_service_perimeter
  ]

  create_duration  = var.time_to_wait_vpc_sc_propagation
  destroy_duration = var.time_to_wait_vpc_sc_propagation
}
