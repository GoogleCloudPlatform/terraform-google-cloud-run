# Simple Cloud Run Example

This example showcases the basic deployment of containerized applications on Cloud Run, along with domain mapping and IAM policy for the service.

The resources/services/activations/deletions that this example will create/trigger are:

* Creates a Cloud Run service with provided name and container

## Assumptions and Prerequisites

This example assumes that below mentioend prerequisites are in place before consuming the example.

* All required APIs are enabled in the GCP Project

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project ID to deploy to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| revision | Deployed revision for the service |
| service\_id | Unique Identifier for the created service |
| service\_location | Location in which the Cloud Run service was created |
| service\_name | Name of the created service |
| service\_status | Status of the created service |
| service\_url | The URL on which the deployed service is available |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this example.

### Software
- [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ~> v3.53+
- [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) ~>
  v3.53+

### Service Account

A service account can be used with required roles to execute this example:

- Cloud Run Admin: `roles/run.admin`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the main resource of this example:

- Google Cloud Run: `run.googleapis.com`
