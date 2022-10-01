# How to customize Foundation v2.3.1 for Secure Serverless deployment

This example deploys the [Secure Cloud Run](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/tree/main/modules/secure-cloud-run) on top of the [Terraform Example Foundation](https://cloud.google.com/architecture/security-foundations/using-example-terraform) version [2.3.1](https://github.com/terraform-google-modules/terraform-example-foundation/tree/v2.3.1).

This example will:

* Create two new projects under each environment folder and each business unit (bu1/bu2) for serverless within the foundation infrastructure.
* Attach the projects to the Restricted Shared VPC foundation network.
* Add all needed API's to the VPC Service Perimeter.
    * Cloud Run API: `run.googleapis.com`
    * Artifact Registry API: `artifactregistry.googleapis.com`
    * Cloud Key Management Service (KMS) API: `cloudkms.googleapis.com`
* Deploy Cloud Run service with a public *hello_world* image (the image can be replaced).
* Create a Serverless VPC Connector on the serverless project.
* Create a set of firewall rules to allow the communication between loadbalancer, serverless, connector, and health-check.
* Create a Loadbalancer with a domain and SSL certificate.
* Create a Network endpoint group (serverless-neg)
* Configure Cloud Armor with [WAF security policy](https://cloud.google.com/armor/docs/cloud-armor-overview#preconfigured_waf_rules).

## Requirements

* [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation/tree/v2.3.1) version 2.3.1 deployed until at least step `4-projects`.
* You must have role **Service Account User** (`roles/iam.serviceAccountUser`) on the [Terraform Service Account](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/GLOSSARY.md#terraform-service-account) created in the foundation [Seed Project](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/GLOSSARY.md#seed-project).
  The Terraform Service Account has the permissions to deploy the foundation.
  * Format: `org-terraform@<SEED_PROJECT_ID>.iam.gserviceaccount.com`.


## Usage

The following instructions details the changes needed in the foundation Terraform configuration to deploy the Secure Cloud Run.

### 0-bootstrap

Grant the following roles related to Secure Cloud Run to the [Terraform Service Account](https://github.com/terraform-google-modules/terraform-example-foundation/blob/v2.3.1/docs/GLOSSARY.md#terraform-service-account) created in the [Seed Project](https://github.com/terraform-google-modules/terraform-example-foundation/blob/v2.3.1/docs/GLOSSARY.md#seed-project)  in step `0-bootstrap`.
* Serverless VPC Access Admin: `roles/vpcaccess.admin`
* Security Admin : `roles/iam.securityAdmin`

To do that:
1. Add `roles/vpcaccess.admin` and `roles/iam.securityAdmin` roles at parent level for the Terraform Service Account in
file [main.tf](https://github.com/terraform-google-modules/terraform-example-foundation/blob/v2.3.1/0-bootstrap/main.tf#L207) in step `0-bootstrap`.
    ```hcl
    resource "google_organization_iam_member" "org_tf_serverless" {
      for_each = toset(var.parent_folder == "" ? ["roles/vpcaccess.admin", "roles/iam.securityAdmin"] : [])
      org_id = var.org_id
      role   = each.key
      member = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
    }

    resource "google_folder_iam_member" "folder_tf_serverless" {
      for_each = toset(var.parent_folder != "" ? ["roles/vpcaccess.admin", "roles/iam.securityAdmin"] : [])
      folder = var.parent_folder
      role   = each.key
      member = "serviceAccount:${module.seed_bootstrap.terraform_sa_email}"
    }
    ```
1. Rerun  `Terraform apply` in step `0-bootstrap` to update the roles.

### 1-org

The Secure Cloud Run requires two Organization Policies related to Cloud Run:

* Allowed ingress settings (Cloud Run)
* Allowed VPC egress settings (Cloud Run)

For the Terraform Example Foundation deploy, use the `terraform-google-modules/org-policy/google` [module](https://registry.terraform.io/modules/terraform-google-modules/org-policy/google/latest)
instead of the specific Secure Cloud Run Security [module](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/tree/main/modules/secure-cloud-run-security) because the Secure Cloud Run Security module also creates KMS resources.

To apply these Organization Policies in Parent Level (Organization or Folder level), add the code below in `1-org` step.

1. Add org policies related to cloud run at `1-org/envs/shared/org_policy.tf`

   ```hcl
   /******************************************
   Cloud Run
   *******************************************/

   module "cloudrun_allowed_ingress" {
    source  = "terraform-google-modules/org-policy/google"
    version = "~> 5.1"

    constraint        = "constraints/run.allowedIngress"
    organization_id   = local.organization_id
    folder_id         = local.folder_id
    policy_for        = local.policy_for
    policy_type       = "list"
    allow             = ["is:internal-and-cloud-load-balancing"]
    allow_list_length = 1
   }

   module "cloudrun_allowed_vpc_egress" {
    source  = "terraform-google-modules/org-policy/google"
    version = "~> 5.1"

    organization_id   = local.organization_id
    folder_id         = local.folder_id
    policy_for        = local.policy_for
    constraint        = "constraints/run.allowedVPCEgress"
    policy_type       = "list"
    allow             = ["private-ranges-only"]
    allow_list_length = 1
   }
   ```

1. Push the code to your repository in the branch you are working on (development for example).

### 2-environments

Add the **VPC Access API** (`vpcaccess.googleapis.com`) in the list of allowed APIs for the `serviceusage_allow_basic_apis` constraint in the Policy Library Repository used by Terraform Validator. Also enable the VPC Access API in the restricted shared VPC host project:

1. Add `vpcaccess.googleapis.com` in `/policies/constraints/serviceusage_allow_basic_apis.yaml` file in your policy repository (`gcp-policies`) and push the code to the repository.
1. Add `vpcaccess.googleapis.com` on the `activate_apis` list in `restricted_shared_vpc_host_project` module in file `gcp-environments/modules/env_baseline/networking.tf#71`
1. Push the code for the branch in the repository (gcp-environment).

### 4-projects

Create the project where Secure Cloud Run will be deployed.
This project will be attached to the Restricted Shared VPC and added to the Service Perimeter.
Also add the Cloud Run API (`run.googleapis.com`), the Cloud Key Management Service (KMS) API (`cloudkms.googleapis.com`), and the Artifact Registry API (`artifactregistry.googleapis.com`) in the Policy Library Repository used by Terraform Validator.

1. Add `run.googleapis.com`, `cloudkms.googleapis.com`, `artifactregistry.googleapis.com` in `/policies/constraints/serviceusage_allow_basic_apis.yaml` file in your policy repository (gcp-policies) and push the code to it.
1. Duplicate the file in each business unit and environment `business_unit_[number]/[environment]/example_restricted_shared_vpc_project.tf` and rename it to `example_restricted_shared_vpc_serverless_project` in your projects repository (gcp-projects).
1. Replace the code in `example_restricted_shared_vpc_serverless_project.tf` file with the following code (in the `locals` section, replace values according to the environment and the business code):


   ```hcl
        /**
        * Copyright 2021 Google LLC
        *
        * Licensed under the Apache License, Version 2.0 (the "License");
        * you may not use this file except in compliance with the License.
        * You may obtain a copy of the License at
        *
        * http://www.apache.org/licenses/LICENSE-2.0
        *
        * Unless required by applicable law or agreed to in writing, software
        * distributed under the License is distributed on an "AS IS" BASIS,
        * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        * See the License for the specific language governing permissions and
        * limitations under the License.
        */
        locals {
            env           = "production"
            business_code = "bu1"
        }

        module "restricted_shared_vpc_serverless_project" {
            source                      = "../../modules/single_project"
            org_id                      = var.org_id
            billing_account             = var.billing_account
            folder_id                   = data.google_active_folder.env.name
            impersonate_service_account = var.terraform_service_account
            environment                 = local.env
            vpc_type                    = "restricted"
            alert_spent_percents        = var.alert_spent_percents
            alert_pubsub_topic          = var.alert_pubsub_topic
            budget_amount               = var.budget_amount
            project_prefix              = var.project_prefix
            enable_hub_and_spoke        = var.enable_hub_and_spoke
            enable_cloudbuild_deploy    = true
            cloudbuild_sa               = var.app_infra_pipeline_cloudbuild_sa
            sa_roles                    = ["roles/editor"]
            activate_apis = [
                "cloudresourcemanager.googleapis.com",
                "storage-api.googleapis.com",
                "serviceusage.googleapis.com",
                "run.googleapis.com",
                "cloudkms.googleapis.com",
                "iam.googleapis.com",
                "vpcaccess.googleapis.com"
            ]
            vpc_service_control_attach_enabled = "true"
            vpc_service_control_perimeter_name = "accessPolicies/${var.access_context_manager_policy_id}/servicePerimeters/${var.perimeter_name}"
            # Metadata
            project_suffix    = "serverless"
            application_name  = "${local.business_code}-serverless-application"
            billing_code      = "1234"
            primary_contact   = "example@example.com"
            secondary_contact = "example2@example.com"
            business_code     = local.business_code
        }

        resource "google_folder_iam_member" "folder_browser" {
            count  = var.parent_folder != ""? 1 : 0
            folder = var.parent_folder
            role   = "roles/browser"
            member = "serviceAccount:${module.restricted_shared_vpc_serverless_project.sa}"
        }

        resource "google_folder_iam_member" "folder_network_viewer" {
            count  = var.parent_folder != ""? 1 : 0
            folder = var.parent_folder
            role   = "roles/compute.networkViewer"
            member = "serviceAccount:${module.restricted_shared_vpc_serverless_project.sa}"
        }

        module "serverless_security_project" {
            source                      = "../../modules/single_project"
            org_id                      = var.org_id
            billing_account             = var.billing_account
            folder_id                   = data.google_active_folder.env.name
            impersonate_service_account = var.terraform_service_account
            environment                 = local.env
            vpc_type                    = ""
            alert_spent_percents        = var.alert_spent_percents
            alert_pubsub_topic          = var.alert_pubsub_topic
            budget_amount               = var.budget_amount
            project_prefix              = var.project_prefix
            enable_hub_and_spoke        = var.enable_hub_and_spoke
            activate_apis = [
                "cloudresourcemanager.googleapis.com",
                "storage-api.googleapis.com",
                "serviceusage.googleapis.com",
                "cloudkms.googleapis.com",
                "iam.googleapis.com",
                "artifactregistry.googleapis.com"
            ]
            vpc_service_control_attach_enabled = "true"
            vpc_service_control_perimeter_name = "accessPolicies/${var.access_context_manager_policy_id}/servicePerimeters/${var.perimeter_name}"
            # Metadata
            project_suffix    = "security"
            application_name  = "${local.business_code}-security-serverless"
            billing_code      = "1234"
            primary_contact   = "example@example.com"
            secondary_contact = "example2@example.com"
            business_code     = local.business_code
        }
   ```

Now, you will need to add the roles to the service account created in the project,
which is going to be used to deploy the Cloud Run.

1. Add the required Cloud Run roles to the service account, created in the project, that will be used to deploy Cloud Run. Edit the file `gcp-projects/modules/single_project/main.tf` to add the required roles.

   ```hcl
   resource "google_folder_iam_member" "storage_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/storage.admin"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "cloud_run_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/run.admin"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "network_user" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/compute.networkUser"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "service_account_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/iam.serviceAccountAdmin"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "compute_security_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/compute.securityAdmin"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "iam_security_reviewer" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/iam.securityReviewer"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "browser" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/browser"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "load_balancer_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/compute.loadBalancerAdmin"
    member = "serviceAccount:${module.project.service_account_email}"
   }

   resource "google_folder_iam_member" "kms_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/cloudkms.admin"
    member = "serviceAccount:${module.project.service_account_email}"
   }

    resource "google_folder_iam_member" "artifact_registry_admin" {
    count  = var.enable_cloudbuild_deploy ? 1 : 0
    folder = var.folder_id
    role   = "roles/artifactregistry.admin"
    member = "serviceAccount:${module.project.service_account_email}"
    }
   ```

1. Add the outputs in files `gcp-projects/business_unit_[number]/[environment]/outputs.tf`

    ```hcl
    output "restricted_serverless_project" {
        description = "Serverless project id."
        value       = module.restricted_shared_vpc_serverless_project.project_id
    }

    output "security_project" {
        description = "Serverless security project id."
        value       = module.serverless_security_project.project_id
    }
    ```

1. Push the code to your repository in the branch you are working on (development for example).

### 3-network

You will add the Cloud Run, Cloud KMS and Artifact Register services to the Restricted Services in the Service Perimeter.

1. Add `run.googleapis.com`, `artifactregistry.googleapis.com`, `cloudkms.googleapis.com` in
files `envs/[environment]/main.tf#103`  - `restricted_services` module variable in you network module (gcp-network)
1. Add the Serverless Project Service Account and the Cloud Build Service Account as members of the perimeter. In `envs/[environment]/main.tf#104` add  - `members` module variable in you network module (gcp-network)

    ```hcl
    members = [
        "serviceAccount:${var.terraform_service_account}",
        "serviceAccount:project-service-account@<YOUR-SERVERLESS-PROJECT>.iam.gserviceaccount.com",
        "serviceAccount:<APP-CLOUDBUILD-PROJECT-NUMBER>@cloudbuild.gserviceaccount.com"
    ]
    ```

1. Add `secure-cloud-run-net` module in file `envs/[environment]/main.tf` module in you network module (gcp-network)

    ```hcl
    data "google_projects" "serverless_project" {
        filter = "parent.id:${split("/", data.google_active_folder.env.name)[1]} labels.application_name=bu1-serverless-application labels.environment=${local.env} lifecycleState=ACTIVE"
    }

    module "serverless_network" {
        source = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-run-net"
        version = "~> 0.3.0"

        connector_name = "con-${local.environment_code}-${var.default_region1}-run"
        shared_vpc_name = module.restricted_shared_vpc.network_name
        subnet_name = "sb-${local.environment_code}-run-${var.default_region1}"
        location = var.default_region1
        vpc_project_id = local.restricted_project_id
        serverless_project_id = data.google_projects.serverless_project.projects[0].project_id
        ip_cidr_range = "10.8.0.0/28"
        connector_on_host_project = false
    }
    ```

1. Push code to the environment branch in gcp-network repository

### 5-app-infra

Deploy the Secure Cloud Run with Load Balancer and Cloud Armor.
To do this deploy, you will replace the example in `5-app-infra` and instead of creating a Compute Engine, you will deploy the Secure Cloud Run.

_This is an *example* of deployment. It will create a Artifact Registry and copy a public image to it to exemplify the deployment using a private Artifact Registry._

1. Add `secure-cloud-run-core` module in `/5-app-infra/modules/env_base/main.tf`

   ```hcl
    /**
    * Copyright 2022 Google LLC
    *
    * Licensed under the Apache License, Version 2.0 (the "License");
    * you may not use this file except in compliance with the License.
    * You may obtain a copy of the License at
    *
    * http://www.apache.org/licenses/LICENSE-2.0
    *
    * Unless required by applicable law or agreed to in writing, software
    * distributed under the License is distributed on an "AS IS" BASIS,
    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    * See the License for the specific language governing permissions and
    * limitations under the License.
    */
    locals {
        environment_code = element(split("", var.environment), 0)
        key_name         = "secure-cloud-run"
    }
    resource "google_service_account" "cloudrun_service_account" {
        project      = data.google_project.env_project.project_id
        account_id   = "sa-example-app"
        display_name = "Example app service Account"
    }
    resource "google_service_account_iam_member" "run_identity_terraform_sa_impersonate_permissions" {
        service_account_id = google_service_account.cloudrun_service_account.id
        role               = "roles/iam.serviceAccountUser"
        member             = "serviceAccount:${google_project_service_identity.serverless_sa.email}"
    }
    resource "random_id" "kms_random" {
        byte_length = 4
    }

    module "kms" {
        source     = "terraform-google-modules/kms/google"
        version    = "~> 2.2"
        project_id = data.google_project.sec_project.project_id
        keyring    = "kms-secure-cloud-run-${random_id.kms_random.hex}"
        location   = var.region
        keys       = [local.key_name, "artifact-registry"]
        encrypters = [
            "serviceAccount:${google_service_account.cloudrun_service_account.email},serviceAccount:${google_project_service_identity.serverless_sa.email}",
            "serviceAccount:${google_project_service_identity.artifact_sa.email}"
        ]
        set_encrypters_for = [local.key_name, "artifact-registry"]
        decrypters = [
            "serviceAccount:${google_service_account.cloudrun_service_account.email},serviceAccount:${google_project_service_identity.serverless_sa.email}",
            "serviceAccount:${google_project_service_identity.artifact_sa.email}"
        ]
        set_decrypters_for = [local.key_name, "artifact-registry"]
        prevent_destroy    = "false"
        depends_on = [
            google_service_account.cloudrun_service_account,
            google_project_service_identity.serverless_sa
        ]
    }

    module "cloud_run_core" {
        source           = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-run.git//modules/secure-cloud-run-core?ref=main"
        service_name     = "example-secure-cloudrun"
        location         = var.region
        project_id       = data.google_project.env_project.project_id
        region           = var.region
        image            = var.image
        cloud_run_sa     = google_service_account.cloudrun_service_account.email
        vpc_connector_id = "projects/${data.google_project.env_project.project_id}/locations/${var.region}/connectors/${var.vpc_connector_name}"
        encryption_key   = module.kms.keys[local.key_name]
        members          = var.members
        domain           = var.domain
        depends_on = [
            google_service_account_iam_member.run_identity_terraform_sa_impersonate_permissions
        ]
    }

    resource "google_project_service_identity" "artifact_sa" {
        provider = google-beta

        project = data.google_project.sec_project.project_id
        service = "artifactregistry.googleapis.com"
    }

    resource "google_artifact_registry_repository" "repo" {
        project       = data.google_project.sec_project.project_id
        location      = var.region
        repository_id = "rep-secure-cloud-run"
        description   = "Repository to store Serverles Docker Image"
        format        = "DOCKER"
        kms_key_name  = module.kms.keys["artifact-registry"]
    }

    resource "google_artifact_registry_repository_iam_member" "member" {
        project    = data.google_project.sec_project.project_id
        location   = var.region
        repository = google_artifact_registry_repository.repo.repository_id
        role       = "roles/artifactregistry.reader"
        member     = "serviceAccount:${google_project_service_identity.serverless_sa.email}"
    }

    resource "null_resource" "copy_image" {
        provisioner "local-exec" {
            command = "gcloud container images add-tag us-docker.pkg.dev/cloudrun/container/hello:latest ${var.region}-docker.pkg.dev/${data.google_project.sec_project.project_id}/${google_artifact_registry_repository.repo.repository_id}/hello:latest -q"
        }
    }
   ```

1. Replace the code file in `/5-app-infra/modules/env_base/data.tf` with:

   ```hcl
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

    data "google_projects" "environment_projects" {
        filter = "parent.id:${split("/", var.folder_id)[1]} name:*${var.project_suffix}* labels.application_name=${var.business_code}-serverless-application labels.environment=${var.environment} lifecycleState=ACTIVE"
    }

    data "google_project" "env_project" {
        project_id = data.google_projects.environment_projects.projects[0].project_id
    }

    data "google_project" "sec_project" {
        project_id = data.google_projects.security_projects.projects[0].project_id
    }

    data "google_projects" "security_projects" {
        filter = "parent.id:${split("/", var.folder_id)[1]} name:*security* labels.application_name=${var.business_code}-security-serverless labels.environment=${var.environment} lifecycleState=ACTIVE"
    }

    resource "google_project_service_identity" "serverless_sa" {
        provider = google-beta
        project  = data.google_project.env_project.project_id
        service  = "run.googleapis.com"
    }
   ```

1. Replace the code file in `/5-app-infra/modules/env_base/variables.tf` with:

    ```hcl
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

    variable "environment" {
        description = "The environment the single project belongs to"
        type        = string
    }

    variable "domain" {
        description = "Your domain."
        type        = string
    }

    variable "members" {
        description = "The users who can invoke cloud run."
        type        = list(string)
    }

    variable "vpc_connector_name" {
        description = "The VPC Serverless Connector name."
        type        = string
    }

    variable "image" {
        description = "The docker image to be deployed in Cloud Run."
        type        = string
    }

    variable "region" {
        description = "The GCP region to create and test resources in"
        type        = string
        default     = "us-central1"
    }

    variable "folder_id" {
        description = "The folder id where project will be created"
        type        = string
    }

    variable "business_code" {
        description = "The code that describes which business unit owns the project"
        type        = string
        default     = "abcd"
    }

    variable "project_suffix" {
        description = "The name of the GCP project. Max 16 characters with 3 character business unit code."
        type        = string
    }
    ```

1. Replace the code file in `/5-app-infra/modules/env_base/outputs.tf` with:

    ```hcl
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

    output "kms_keyring_selflink" {
        description = "Self link of the keyring."
        value       = module.restricted_serverless.kms_keyring_selflink
    }

    output "kms_key" {
        description = "Key name used by Cloud Run."
        value       = module.restricted_serverless.kms_key
    }

    output "cloud_run_service" {
        description = "Cloud Run service status."
        value       = module.restricted_serverless.cloud_run_service
    }

    ```

1. Replace the code file in `/5-app-infra/business_unit_[bu]/[env]/main.tf` with:

    ```hcl
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



    data "google_active_folder" "env" {
        display_name = "${var.folder_prefix}-production"
        parent       = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
    }

    module "restricted_serverless" {
        source             = "../../modules/env_base"
        environment        = "production"
        image              = "${var.region}-docker.pkg.dev/${module.restricted_serverless.security_project_id}/${module.restricted_serverless.artifact_registry_repository_name}/hello:latest"
        vpc_connector_name = "con-p-${var.region}-run"
        folder_id          = data.google_active_folder.env.name
        business_code      = "bu1"
        project_suffix     = "serverless"
        region             = var.region
        domain             = var.domain
        members            = var.members
    }

    ```

1. Replace the code file in `/5-app-infra/business_unit_[bu]/[env]/variables.tf` with:

    ```hcl
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

    variable "project_service_account" {
        description = "Email of the service account created on step 4-projects for the business unit 1 sample base project where the GCE instance will be created"
        type        = string
    }

    variable "org_id" {
        description = "The organization id for the associated services"
        type        = string
    }

    variable "folder_prefix" {
        description = "Name prefix to use for folders created. Should be the same in all steps."
        type        = string
        default     = "fldr"
    }

    variable "parent_folder" {
        description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step."
        type        = string
        default     = ""
    }

    variable "domain" {
        description = "Your domain."
        type        = string
    }

    variable "members" {
        description = "The users who can invoke Cloud Run."
        type        = list(string)
    }

    variable "region" {
        description = "The GCP region to create and test resources in"
        type        = string
        default     = "us-central1"
    }
    ```

1. Replace the code file in `/5-app-infra/business_unit_[bu]/[env]/outputs.tf` with:

    ```hcl
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

    output "kms_keyring_selflink" {
        description = "Self link of the keyring."
        value       = module.restricted_serverless.kms_keyring_selflink
    }

    output "kms_key" {
        description = "Key name used by Cloud Run."
        value       = module.restricted_serverless.kms_key
    }

    output "cloud_run_service" {
        description = "Cloud Run service status."
        value       = module.restricted_serverless.cloud_run_service
    }
    ```

1. Change the project_service_account on your environments file (eg.: bu1-development.auto.tfvars) to the service account from serverless project (eg.: project-service-account@<SERVERLESS_PROJECT_ID>.iam.gserviceaccount.com)
1. Push code to the bu[number]-example-app repository.
