# Secure Cloud Run Harness

This module creates the infrastructure required by Secure Cloud Run module.

This module deploys:

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

## Usage

Basic usage of this module is as follows:

```hcl
module "secure_cloud_run_harness" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-run-harness"
  version = "~> 0.3.0"

  # Required variables
  billing_account                   = "<BILLING ACCOUNT>"
  security_project_name             = "<SECURITY PROJECT NAME>"
  serverless_project_name           = "<SERVERLESS PROJECT NAME>"
  org_id                            = "<ORGANIZATION ID>"
  region                            = "<REGION>"
  location                          = "<LOCATION>"
  vpc_name                          = "<VPC NAME>"
  subnet_ip                         = "<SUBNET IP RANGE>"
  artifact_registry_repository_name = "<ARTIFACT REGISTRY NAME>"
  keyring_name                      = "<KEYRING NAME>"
  key_name                          = "<KEY NAME>"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The ID of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `number` | `null` | no |
| access\_level\_members | The list of additional members who will be in the access level. | `list(string)` | n/a | yes |
| additional\_restricted\_services | The list of additional services which will be in the perimeter. | `list(string)` | `[]` | no |
| artifact\_registry\_repository\_description | The description of the Artifact Registry Repository to be created. | `string` | `"Secure Cloud Run Artifact Registry Repository"` | no |
| artifact\_registry\_repository\_format | The format of the Artifact Registry Repository to be created. | `string` | `"DOCKER"` | no |
| artifact\_registry\_repository\_name | The name of the Artifact Registry Repository to be created. | `string` | n/a | yes |
| billing\_account | The ID of the billing account to associate this project with. | `string` | n/a | yes |
| create\_access\_context\_manager\_access\_policy | Defines if Access Context Manager will be created by Terraform. | `bool` | `false` | no |
| decrypters | List of comma-separated owners for each key declared in set\_decrypters\_for. | `list(string)` | `[]` | no |
| dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for VPC DNS. | `bool` | `true` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference), each list object has a `from` and `to` value that describes egress\_from and egress\_to.<br><br>Example: `[{ from={ identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions). | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| encrypters | List of comma-separated owners for each key declared in set\_encrypters\_for. | `list(string)` | `[]` | no |
| ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions). | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| key\_name | Key name. | `string` | n/a | yes |
| key\_protection\_level | The protection level to use when creating a version based on this template. Possible values: ["SOFTWARE", "HSM"]. | `string` | `"HSM"` | no |
| key\_rotation\_period | Period of key rotation in seconds. Default value is equivalent to 30 days. | `string` | `"2592000s"` | no |
| keyring\_name | Keyring name. | `string` | n/a | yes |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| org\_id | The organization ID. | `string` | n/a | yes |
| owners | List of comma-separated owners for each key declared in set\_owners\_for. | `list(string)` | `[]` | no |
| parent\_folder\_id | The ID of a folder to host the infrastructure created in this module. | `string` | `""` | no |
| prevent\_destroy | Set the prevent\_destroy lifecycle attribute on keys. | `bool` | `true` | no |
| private\_service\_connect\_ip | The internal IP to be used for the private service connect. | `string` | n/a | yes |
| region | The region in which the subnetwork will be created. | `string` | n/a | yes |
| security\_project\_name | The name to give the security project. | `string` | n/a | yes |
| serverless\_folder\_suffix | The suffix to be concat in the Serverless folder name fldr-serverless-<SUFFIX>. | `string` | `""` | no |
| serverless\_project\_name | The name to give the Cloud Run project. | `string` | n/a | yes |
| service\_account\_project\_roles | Common roles to apply to the Cloud Run service account in the serverless project. | `list(string)` | `[]` | no |
| subnet\_ip | The CDIR IP range of the subnetwork. | `string` | n/a | yes |
| vpc\_name | The name of the network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| artifact\_registry\_repository\_id | The Artifact Registry Repository full identifier where the images should be stored. |
| artifact\_registry\_repository\_name | The Artifact Registry Repository last part of the repository name where the images should be stored. |
| cloud\_run\_service\_identity\_email | The Cloud Run Service Identity email. |
| restricted\_access\_level\_name | Access level name. |
| restricted\_service\_perimeter\_name | Service Perimeter name. |
| security\_project\_id | Project ID of the project created for KMS and Artifact Register. |
| security\_project\_number | Project number of the project created for KMS and Artifact Register. |
| serverless\_folder\_id | The folder created to alocate Serverless infra. |
| serverless\_project\_id | Project ID of the project created to deploy Cloud Run. |
| serverless\_project\_number | Project number of the project created to deploy Cloud Run. |
| service\_account\_email | The email of the Service Account created to be used by Cloud Run. |
| service\_subnet | The sub-network name created in harness. |
| service\_vpc | The network created for Cloud Run. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

* [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) < 5.0
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
