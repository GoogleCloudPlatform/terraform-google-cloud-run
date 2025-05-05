# Cloud Run service continuously deployed from a Git repository

This example showcases configuring the [continuous deployment](https://cloud.google.com/run/docs/continuous-deployment-with-cloud-build) of a Run service.
Once provisioned, it uses Cloud Build trigger to automatically build and deploy changes committed to a configured branch of the Git repository connected to Artifact Registry.

The resources/services/activations/deletions that this example uses are:

* Cloud Build, Artifact Registry, Secret Manager and Cloud Run APIs
* Creates a Service Account to be used ????? (TODO: more details on how the account is used).
* Creates a Cloud Run service.
* Register a Github repository ???? (TODO: more details on where it is registered).
* Creates a new Cloud Build trigger and configure it to deploy a new version of the Cloud Run service from source code in the repository.

> [!NOTE]
> This example uses the default Cloud Build service account. (TODO: enumerate roles that narrow the scope of SA for CB)

## Usage

To provision this example, run the following from within this directory:

* Rename `terraform.example.tfvars` to `terraform.tfvars` by running `mv terraform.example.tfvars terraform.tfvars` shell command and update the file with values from your environment.
* Run `terraform init` shell command to get the plugins
* Run `terraform plan` shell command to see the infrastructure plan
* Run `terraform apply` shell command to apply the infrastructure build

### Clean up

* Run `terraform destroy` to shutdown and delete all resources and clean up your environment.
  > [!NOTE]
  > Some APIs may stay enabled. Enabled APIs do not generate billing by themselves.

## Assumptions and Prerequisites

To run this example you need to ensure the following:

* Install the [Cloud Build App][cb_app] on Github for repositories you plan to use for continuous deployment.
* Create a [Personal Access Token][github_token] on Github with [scopes][token_scopes] `repo` and `read:user` (or if app is installed in a organization use `read:org`).
  > [!NOTE]
  > Terraform [does not support][support_msg1] Cloud Build 1st gen repositories
* Environment where Terraform is ran can authenticate vs Github to access the repository and provided identity has permissions to enable Github applications on this repository
* Google Cloud identity used to run Terraform has the following roles or similar permissions:

  * Artifact Registry Administrator (`roles/artifactregistry.admin`)
  * Cloud Build Editor (`roles/cloudbuild.builds.editor`)
  * Cloud Run Developer (`roles/run.developer`)
  * Service Account User (`roles/iam.serviceAccountUser`)
  * Service Usage Admin (`roles/serviceusage.serviceUsageAdmin`)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| github\_repo | URI of the Git repository for CD | `string` | n/a | yes |
| github\_app_id_secret | The secret ID that stores the installation ID[^1] of the Cloud Build for Github. | `string` | n/a | yes |
| github\_ | URI of the Git repository for CD | `string` | n/a | yes |
| region\_id | The region to deploy the service (also used for Cloud Build) | `string` | `us-central1` | no |
| branch\_name | The branch to be used for CD | `string` | `main` | no |
| service\_name | Name of the new Cloud Run service | `string` | `example_service_with_cd` | no |

[^1]: Installation ID can be derived from the [installed Github app][github_app] URL.
  The URL has a format `https://github.com/settings/installations/ID` or `https://github.com/apps/APP_NAME/installations/ID`.
  Copy ID from the last element of the URL path.

## Outputs

| Name | Description |
|------|-------------|
| service\_id | Unique Identifier for the created service |
| service\_location | Location in which the Cloud Run service was created |
| service\_name | Name of the created service |
| service\_status | Status of the created service |
| service\_url | The URL on which the deployed service is available |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this example.

### Software

* [Terraform](https://www.terraform.io/downloads.html) ~> ????
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ???

[cb_app]: https://github.com/apps/google-cloud-build
[github_token]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
[token_scopes]: https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps#available-scopes
[support_msg1]: https://cloud.google.com/build/docs/repositories?_gl=1#1st-gen-repos
[github_app]: https://docs.github.com/en/apps/using-github-apps/installing-your-own-github-app
