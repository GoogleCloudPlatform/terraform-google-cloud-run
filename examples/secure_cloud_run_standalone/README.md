# Secure Cloud Run Standalone Example

This example showcases the full deployment Secure Cloud Run with harness infrastructure.

The resources/services/activations/deletions that this example will create/trigger are:

* A folder to store Serverless infrastructure.
* A project to deploy Cloud run.
* A project to store KMS and Artifact Register.
  * Keyring and Key created for Artifact Register.
  * Artifact Register created with Encryption Key.
  * Hello World example image copied to Artifact Register.
* A network and one subnetwork.
* Firewall rules:
  * Deny all egress traffic.
  * Allow Restricted and Private Google APIs.
* Configure a Private Service Connect.
* Creates an Access Level and a Service Perimeter with both projects and with the services restricted:
  * Cloud KMS.
  * Cloud Run.
  * Artifact Register.
  * Container Register.
  * Container Analysis.
  * Binary Authorization.
* A Service Account to be used by Cloud Run.
* Creates Load Balancer
* Creates Cloud Armor
* Creates Organization Policies in Serverless Project level.
* Creates Serverless VPC Connector.
* Creates Firewall rules for Serverless VPC Access.
* Creates KMS Keyring and Key for Cloud Run usage.
* Creates a Cloud Run service.

## Assumptions and Prerequisites

This example assumes that below mentioned prerequisites are in place before consuming the example.

* An Organization.
* A Billing Account.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `number` | `null` | no |
| billing\_account | The ID of the billing account to associate this project with. | `string` | n/a | yes |
| create\_access\_context\_manager\_access\_policy | Defines if Access Context Manager will be created by Terraform. | `bool` | `false` | no |
| domain | Domain name to run the load balancer on. | `string` | n/a | yes |
| org\_id | The organization ID. | `string` | n/a | yes |
| parent\_folder\_id | The ID of a folder to host the infrastructure created in this example. | `string` | `""` | no |
| perimeter\_members | The list of members who will be in the access level. | `list(string)` | `[]` | no |
| serverless\_folder\_suffix | The suffix to be concat in the Serverless folder name fldr-serverless-<SUFFIX>. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| artifact\_registry\_repository\_id | The Artifact Registry Repository ID where the images should be stored. |
| artifact\_registry\_repository\_name | The Artifact Registry Repository last part of the repository name where the images should be stored. |
| connector\_id | VPC serverless connector ID. |
| restricted\_access\_level\_name | Access level name. |
| restricted\_service\_perimeter\_name | Service Perimeter name. |
| security\_project\_id | The security project id. |
| security\_project\_number | The security project number. |
| serverless\_project\_id | The serverless project id. |
| serverless\_project\_number | The serverless project number. |
| service\_account\_email | The service account email created to be used by Cloud Run. |
| service\_vpc\_name | The Network self-link created in harness. |
| service\_vpc\_self\_link | The Network self-link created in harness. |
| service\_vpc\_subnet\_name | The sub-network name created in harness. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

* [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) >= 3.53, < 5.0
* [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) >= 3.53, < 5.0

### Service Account

A service account can be used with required roles to execute this module:

* Organization Level:
  * Access Context Manager Editor: `roles/accesscontextmanager.policyEditor`
* Parent level - Organization or Folder level:
  * Folder Admin - `roles/resourcemanager.folderAdmin`
  * Project Creator - `roles/resourcemanager.projectCreator`
  * Project Deleter - `roles/resourcemanager.projectDeleter`
* Billing
  * Billing User - `roles/billing.user`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.
