# Secure Cloud Run Standalone Example

This example showcases the full deployment Secure Cloud Run with harness infrastructure included.

The resources/services/activations/deletions that this example will create/trigger are:

* A folder to store Serverless infrastructure.
* The service project where Cloud Run is going to be deployed.
* The security project where KMS and Artifact Registry are going to be created.
  * Keyring and Key created for Artifact Registry.
  * Artifact Registry created with Encryption Key.
  * Hello World example image copied to Artifact Registry.
* A network and one subnetwork.
* Firewall rules:
  * Deny all egress traffic.
  * Allow Restricted and Private Google APIs.
* Configure a Private Service Connect.
* Creates an Access Level and a Service Perimeter with both projects and restricting the services bellow:
  * Cloud KMS.
  * Cloud Run.
  * Artifact Registry.
  * Container Registry.
  * Container Analysis.
  * Binary Authorization.
* A Service Account to be used by Cloud Run.
* Creates Load Balancer at service project.
* Creates Google Cloud Armor with pre-configured WAF rules at service project.
* Creates Organization Policies at service project level.
  * Allowed Ingress: Internal and Cloud Load Balancing Only.
  * Allowed VPC Egress: Private Range Only.
* Creates Serverless VPC Connector at service project.
* Creates Firewall rules for Serverless VPC Access.
* Creates KMS Keyring and Key for Cloud Run usage at security project.
* Creates a Cloud Run service at service project.

## Usage

To provision this example, run the following from within this directory:

- Rename `terraform.example.tfvars` to `terraform.tfvars` by running `mv terraform.example.tfvars terraform.tfvars` and update the file with values from your environment.
- Rename `providers.tf.example` to `providers.tf` by running `mv providers.tf.example providers.tf`. Then, open the `providers.tf` and change the value for the field `impersonate_service_account =` with the Terraform service account that will be used to deploy this example.
- `terraform init` to get the plugins.
- `terraform plan` to see the infrastructure plan.
- `terraform apply` to apply the infrastructure build.

**Note:** The user or service account being used to deploy the `Standalone Example` should be part of the Access Level Perimeter. You must add the account used in the `access_level_members` variable.

### Clean up

- Run `terraform destroy` to clean up your environment.

## Assumptions and Prerequisites

This example assumes that below mentioned prerequisites are in place before consuming the example.

* An Organization.
* A Billing Account.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. This variable must be provided if `create_access_context_manager_access_policy` is set to `false` | `number` | `null` | no |
| access\_level\_members | The list of members who will be in the access level. | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associate this project with. | `string` | n/a | yes |
| create\_access\_context\_manager\_access\_policy | Defines if Access Context Manager will be created by Terraform. If set to `false`, you must provide `access_context_manager_policy_id`. More information about Access Context Manager creation in [this documentation](https://cloud.google.com/access-context-manager/docs/create-access-level). | `bool` | n/a | yes |
| domain | Domain name to run on the load balancer on. | `list(string)` | n/a | yes |
| egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference), each list object has a `from` and `to` value that describes egress\_from and egress\_to.<br><br>Example: `[{ from={ identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions). | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions). | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| org\_id | The organization ID. | `string` | n/a | yes |
| parent\_folder\_id | The ID of a folder to host the infrastructure created in this example. | `string` | `""` | no |
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
  * Organization Policy Administrator: `roles/roles/orgpolicy.policyAdmin`
* Parent level - Organization or Folder level:
  * Folder Admin - `roles/resourcemanager.folderAdmin`
  * Project Creator - `roles/resourcemanager.projectCreator`
  * Project Deleter - `roles/resourcemanager.projectDeleter`
* Billing
  * Billing User - `roles/billing.user`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.
