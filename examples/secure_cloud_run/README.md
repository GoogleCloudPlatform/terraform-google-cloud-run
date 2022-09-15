# Simple Cloud Run Example

This example showcases the basic deployment of containerized applications on Cloud Run, along with domain mapping and IAM policy for the service.

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
| cloud\_run\_sa | Service account to be used on Cloud Run. | `string` | n/a | yes |
| domain | Domain name to run the load balancer on. Used if `ssl` is `true`. | `string` | n/a | yes |
| folder\_id | The folder ID to apply the policy to. | `string` | `""` | no |
| kms\_project\_id | The project where KMS will be created. | `string` | n/a | yes |
| organization\_id | The organization ID to apply the policy to. | `string` | `""` | no |
| policy\_for | Policy Root: set one of the following values to determine where the policy is applied. Possible values: ["project", "folder", "organization"]. | `string` | `"project"` | no |
| serverless\_project\_id | The project where cloud run is going to be deployed. | `string` | n/a | yes |
| shared\_vpc\_name | Shared VPC name which is going to be re-used to create Serverless Connector. | `string` | n/a | yes |
| ssl | Run load balancer on HTTPS and provision managed certificate with provided `domain`. | `bool` | `true` | no |
| vpc\_project\_id | The project where shared vpc is. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_services\_sa | Service Account for Cloud Run Service. |
| connector\_id | VPC serverless connector ID. |
| domain | n/a |
| domain\_map\_id | Unique Identifier for the created domain map. |
| domain\_map\_status | Status of Domain mapping. |
| folder\_id | The folder ID to apply the policy to. |
| gca\_vpcaccess\_sa | Service Account for VPC Access. |
| key\_name | Key name. |
| keyring\_name | Keyring name. |
| kms\_project\_id | The project where KMS will be created. |
| load\_balancer\_ip | IP Address used by Load Balancer. |
| organization\_id | The organization ID to apply the policy to. |
| policy\_for | Policy Root: set one of the following values to determine where the policy is applied. Possible values: ["project", "folder", "organization"]. |
| project\_id | The project where Cloud Run will be created. |
| revision | Deployed revision for the service. |
| run\_identity\_services\_sa | Service Identity to run services. |
| service\_id | Unique Identifier for the created service. |
| service\_status | Status of the created service. |
| service\_url | The URL on which the deployed service is available. |
| shared\_vpc\_name | n/a |
| vpc\_project\_id | The project where VPC Connector is going to be deployed. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this example.

### Software

* [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ~> v3.53+
* [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) ~>
  v3.53+

### Service Account

A service account can be used with required roles to execute this example:

* Cloud Run Admin: `roles/run.admin`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the main resource of this example:

* Google Cloud Run: `run.googleapis.com`
