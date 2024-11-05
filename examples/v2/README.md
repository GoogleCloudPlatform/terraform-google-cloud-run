# Cloud Run Service using v2 API Example

This example showcases the basic deployment of containerized applications on Cloud Run and IAM policy for the service.

The resources/services/activations/deletions that this example will create/trigger are:

* Creates a Cloud Run service with provided name and container
* Creates a Service Account to be used by Cloud Run Service.

## Assumptions and Prerequisites

This example assumes that below mentioned prerequisites are in place before consuming the example.

* All required APIs are enabled in the GCP Project

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_run\_deletion\_protection | This field prevents Terraform from destroying or recreating the Cloud Run v2 Jobs and Services | `bool` | `true` | no |
| project\_id | The project ID to deploy to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| observed\_generation | The generation of this Service currently serving traffic. |
| project\_id | Project ID of the service |
| service\_id | Unique Identifier for the created service with format projects/{{project}}/locations/{{location}}/services/{{name}} |
| service\_location | Location in which the Cloud Run service was created |
| service\_name | Name of the created service |
| service\_uri | The URL on which the deployed service is available |
| traffic\_statuses | Detailed status information for corresponding traffic targets. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this example.

### Software

* [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ~> v5.0+
* [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) ~>
  v5.0+

### Service Account

A service account can be used with required roles to execute this example:

* Cloud Run Admin: `roles/run.admin`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the main resource of this example:

* Google Cloud Run: `run.googleapis.com`
