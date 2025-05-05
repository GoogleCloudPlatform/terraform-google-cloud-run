/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_cloudbuildv2_connection" "github-connection" {
}

resource "google_cloudbuildv2_repository" "github-repository" {
}

resource "google_cloudbuild_trigger" "cd-to-cloud-run" {
}


module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.2"
  project_id = var.project_id
  prefix     = "sa-cloud-run"
  names      = ["cd-demo"]
}

module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.16"

  service_name          = "cd-demo-service"
  project_id            = var.project_id
  location              = "us-central1"
  image                 = "us-docker.pkg.dev/cloudrun/container/hello"
  service_account_email = module.service_account.email
}


connect repository (in cloud build) /* it is 1gen because of the global location; check regional location to validate CD with 2gen */
create cloud build trigger:
- global
- tags:
  * gcp-cloud-build-deploy-cloud-run
  * gcp-cloud-build-deploy-cloud-run-managed
  * {cloud_run_service_name} /* aka identity */
  - source: cloud build repositories /* pointing to connected repository 1gen */
  - inline build configuration /* keep options for cloudbuild file, docker build or buildpacks */
  /*
  **************************************************************************************************************************************
  steps:
  - name: gcr.io/k8s-skaffold/pack
    args:
      - build
      - >-
        $_AR_HOSTNAME/$_AR_PROJECT_ID/$_AR_REPOSITORY/$REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA
      - '--builder=gcr.io/buildpacks/builder:v1'
      - '--network=cloudbuild'
      - '--path=go'
    id: Buildpack
    entrypoint: pack
  - name: gcr.io/cloud-builders/docker
    args:
      - push
      - >-
        $_AR_HOSTNAME/$_AR_PROJECT_ID/$_AR_REPOSITORY/$REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA
    id: Push
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk:slim'
    args:
      - run
      - services
      - update
      - $_SERVICE_NAME
      - '--platform=managed'
      - >-
        --image=$_AR_HOSTNAME/$_AR_PROJECT_ID/$_AR_REPOSITORY/$REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA
      - >-
        --labels=managed-by=gcp-cloud-build-deploy-cloud-run,commit-sha=$COMMIT_SHA,gcb-build-id=$BUILD_ID,gcb-trigger-id=$_TRIGGER_ID
      - '--region=$_DEPLOY_REGION'
      - '--quiet'
    id: Deploy
    entrypoint: gcloud
images:
  - >-
    $_AR_HOSTNAME/$_AR_PROJECT_ID/$_AR_REPOSITORY/$REPO_NAME/$_SERVICE_NAME:$COMMIT_SHA
options:
  substitutionOption: ALLOW_LOOSE
  logging: CLOUD_LOGGING_ONLY
substitutions:
  _AR_PROJECT_ID: test-tf-script-may05
  _PLATFORM: managed
  _SERVICE_NAME: o11y-methods-screen-demo-test1
  _DEPLOY_REGION: us-west1
  _TRIGGER_ID: f0064b9d-3fb9-414f-8ea8-77b5fe97699e
  _AR_HOSTNAME: us-west1-docker.pkg.dev
  _AR_REPOSITORY: cloud-run-source-deploy
tags:
  - gcp-cloud-build-deploy-cloud-run
  - gcp-cloud-build-deploy-cloud-run-managed
  - o11y-methods-screen-demo-test1
**************************************************************************************************************************************
*/

- environment variables:
  * _AR_HOSTNAME: ${service_region}`-docker.pkg.dev`
  * _AR_PROJECT_ID: ${project_id}
  * _AR_REPOSITORY: `cloud-run-source-deploy`
  * _DEPLOY_REGION: ${service_region}
  * _PLATFORM: `managed`
  * _SERVICE_NAME: ${service_name}
  * _TRIGGER_ID: ${cloud_build_trigger_id}

- send build logs to github
- use compute service account /* note that it is suboptimal since it has wide range of permissions */

