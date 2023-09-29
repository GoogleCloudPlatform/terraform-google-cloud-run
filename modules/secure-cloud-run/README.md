# Secure Cloud Run

This module handles the deployment required for Cloud Run usage. Secure-cloud-run module will call the secure-cloud-run-core, secure-serverless-net and secure-cloud-run-security modules.

When using a Shared VPC, you can chose where to create the VPC Connector.

_Note:_ When using a single VPC you should provides VPC and Serverless project id with the same value and the value for `connector_on_host_project` variable must be `false`.

The resources/services/activations/deletions that this module will create/trigger are:

* secure-serverless-net module will apply:
  * Creates Firewall rules on your **VPC Project**.
    * Serverless to VPC Connector
    * VPC Connector to Serverless
    * VPC Connector to LB
    * VPC Connector Health Checks
  * Creates a sub network to VPC Connector usage purpose.
  * Creates Serverless Connector on your **VPC Project** or **Serverless Project**. Refer the comparison below:
    * Advantages of creating connectors in the [VPC Project](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#host-project)
    * Advantages of creating connectors in the [Serverless Project](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#service-projects)
  * Grant the necessary roles for Cloud Run be able to use VPC Connector on your Shared VPC when creating VPC Connector in host project.
    * Grant Network User role to Cloud Services service account.
    * Grant VPC Access User to Cloud Run Service Identity when deploying VPC Access.

* secure-cloud-run-security module will apply:
  * Creates KMS Keyring and Key for [customer managed encryption keys](https://cloud.google.com/run/docs/securing/using-cmek) in the **KMS Project** to be used by Cloud Run.
  * Enables Organization Policies related to Cloud Run in the **Serverless Project**.
  * Allow Ingress only from internal and Cloud Load Balancing.
  * Allow VPC Egress to Private Ranges Only.
  * When groups emails are provided, this module will grant the roles for each persona.
    * Serverless Administrator - **Service Project**
      * Cloud Run Administrator: `roles/run.admin`
      * Cloud Compute Network Viewer: `roles/compute.networkViewer`
      * Cloud Compute Network User: `compute.networkUser`
    * Servervless Security Administrator - **Security Project**
      * Cloud Run Viewer: `roles/run.viewer`
      * Cloud KMS Viewer: `roles/cloudkms.viewer`
      * roles/artifactregistry.reader
    * Cloud Run developer - **Security Project**
      * Cloud Run Develper: `roles/run.developer`
      * Cloud Run: `roles/artifactregistry.writer`
      * Cloud Run KMS Encrypter: `roles/cloudkms.cryptoKeyEncrypter`
    * Cloud Run user - **Security Project**
      * Cloud Run Invoker: `roles/run.invoker`

* secure-cloud-run-core module will apply:
  * Creates a Cloud Run Service.
  * Creates a Load Balancer Service using Google-managed SSL certificates.
  * Creates Cloud Armor Service only including the pre-configured rules for SQLi, XSS, LFI, RCE, RFI, Scannerdetection, Protocolattack and Sessionfixation.

## Usage

Basic usage of this module is as follows:

```hcl
module "secure_cloud_run" {
  source = "../modules/secure-cloud-run"

  vpc_project_id                          = <VPC Project ID>
  kms_project_id                          = <KMS Project ID>
  serverless_project_id                   = <Serverless Project ID>
  domain                                  = <Domain>
  shared_vpc_name                         = <Shared VPC Name
  ip_cidr_range                           = <IP CIDR Range>
  service_name                            = <Service Name>
  location                                = <Location>
  region                                  = <Region>
  image                                   = <Image>
  cloud_run_sa                            = <Cloud Run Service Account>
  artifact_registry_repository_location   = <Artifact Registry Repository Location>
  artifact_registry_repository_name       = <Artifact Registry Repository Name>
  artifact_registry_repository_project_id = <Artifact Registry Repository Project ID>
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| artifact\_registry\_repository\_location | Artifact Registry Repository location to grant serverless identity viewer role. | `string` | `null` | no |
| artifact\_registry\_repository\_name | Artifact Registry Repository name to grant serverless identity viewer role | `string` | `null` | no |
| artifact\_registry\_repository\_project\_id | Artifact Registry Repository Project ID to grant serverless identity viewer role. | `string` | `null` | no |
| cloud\_armor\_policies\_name | Cloud Armor policy name already created in the project. If `create_cloud_armor_policies` is `false`, this variable must be provided, If `create_cloud_armor_policies` is `true`, this variable will be ignored. | `string` | `null` | no |
| cloud\_run\_sa | Service account to be used on Cloud Run. | `string` | n/a | yes |
| connector\_name | The name for the connector to be created. | `string` | `"serverless-vpc-connector"` | no |
| create\_cloud\_armor\_policies | When `true`, the terraform will create the Cloud Armor policies. When `false`, the user must provide their own Cloud Armor name in `cloud_armor_policies_name`. | `bool` | `true` | no |
| create\_subnet | The subnet will be created with the subnet\_name variable if true. When false, it will use the subnet\_name for the subnet. | `bool` | `true` | no |
| env\_vars | Environment variables (cleartext) | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| folder\_id | The folder ID to apply the policy to. | `string` | `""` | no |
| grant\_artifact\_register\_reader | When true it will grant permission to read an image from your artifact registry. When true, you must provide `artifact_registry_repository_project_id`, `artifact_registry_repository_location` and `artifact_registry_repository_name`. | `bool` | `false` | no |
| groups | Groups which will have roles assigned.<br>  The Serverless Administrators email group which the following roles will be added: Cloud Run Admin, Compute Network Viewer and Compute Network User.<br>  The Serverless Security Administrators email group which the following roles will be added: Cloud Run Viewer, Cloud KMS Viewer and Artifact Registry Reader.<br>  The Cloud Run Developer email group which the following roles will be added: Cloud Run Developer, Artifact Registry Writer and Cloud KMS CryptoKey Encrypter.<br>  The Cloud Run User email group which the following roles will be added: Cloud Run Invoker. | <pre>object({<br>    group_serverless_administrator          = optional(string, null)<br>    group_serverless_security_administrator = optional(string, null)<br>    group_cloud_run_developer               = optional(string, null)<br>    group_cloud_run_user                    = optional(string, null)<br>  })</pre> | `{}` | no |
| image | Image url to be deployed on Cloud Run. | `string` | n/a | yes |
| ip\_cidr\_range | The range of internal addresses that are owned by the subnetwork and which is going to be used by VPC Connector. For example, 10.0.0.0/28 or 192.168.0.0/28. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported. | `string` | n/a | yes |
| key\_name | The name of KMS Key to be created and used in Cloud Run. | `string` | `"cloud-run-kms-key"` | no |
| key\_protection\_level | The protection level to use when creating a version based on this template. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| key\_rotation\_period | Period of key rotation in seconds. | `string` | `"2592000s"` | no |
| keyring\_name | Keyring name. | `string` | `"cloud-run-kms-keyring"` | no |
| kms\_project\_id | The project where KMS will be created. | `string` | n/a | yes |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| max\_scale\_instances | Sets the maximum number of container instances needed to handle all incoming requests or events from each revison from Cloud Run. For more information, access this [documentation](https://cloud.google.com/run/docs/about-instance-autoscaling). | `number` | `2` | no |
| members | Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users.` | `list(string)` | `[]` | no |
| min\_scale\_instances | Sets the minimum number of container instances needed to handle all incoming requests or events from each revison from Cloud Run. For more information, access this [documentation](https://cloud.google.com/run/docs/about-instance-autoscaling). | `number` | `1` | no |
| organization\_id | The organization ID to apply the policy to. | `string` | `""` | no |
| policy\_for | Policy Root: set one of the following values to determine where the policy is applied. Possible values: ["project", "folder", "organization"]. | `string` | `"project"` | no |
| prevent\_destroy | Set the `prevent_destroy` lifecycle attribute on the Cloud KMS key. | `bool` | `true` | no |
| region | Location for load balancer and Cloud Run resources. | `string` | n/a | yes |
| resource\_names\_suffix | A suffix to concat in the end of the network resources names being created. | `string` | `null` | no |
| serverless\_project\_id | The project to deploy the cloud run service. | `string` | n/a | yes |
| service\_name | Shared VPC name. | `string` | n/a | yes |
| shared\_vpc\_name | Shared VPC name which is going to be re-used to create Serverless Connector. | `string` | n/a | yes |
| ssl\_certificates | A object with a list of domains to auto-generate SSL certificates or a list of SSL Certificates self-links in the pattern `projects/<PROJECT-ID>/global/sslCertificates/<CERT-NAME>` to be used by Load Balancer. | <pre>object({<br>    ssl_certificates_self_links       = list(string)<br>    generate_certificates_for_domains = list(string)<br>  })</pre> | n/a | yes |
| subnet\_name | Subnet name to be re-used to create Serverless Connector. | `string` | `null` | no |
| verified\_domain\_name | List of Custom Domain Name | `list(string)` | `[]` | no |
| volumes | [Beta] Volumes needed for environment variables (when using secret). | <pre>list(object({<br>    name = string<br>    secret = set(object({<br>      secret_name = string<br>      items       = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| vpc\_egress\_value | Sets VPC Egress firewall rule. Supported values are all-traffic, all (deprecated), and private-ranges-only. all-traffic and all provide the same functionality. all is deprecated but will continue to be supported. Prefer all-traffic. | `string` | `"private-ranges-only"` | no |
| vpc\_project\_id | The host project for the shared vpc. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_services\_sa | Service Account for Cloud Run Service. |
| connector\_id | VPC serverless connector ID. |
| domain\_map\_id | Unique Identifier for the created domain map. |
| domain\_map\_status | Status of Domain mapping. |
| gca\_vpcaccess\_sa | Service Account for VPC Access. |
| key\_self\_link | Name of the Cloud KMS crypto key. |
| keyring\_self\_link | Name of the Cloud KMS keyring. |
| load\_balancer\_ip | IP Address used by Load Balancer. |
| revision | Deployed revision for the service. |
| run\_identity\_services\_sa | Service Identity to run services. |
| service\_id | ID of the created service. |
| service\_status | Status of the created service. |
| service\_url | Url of the created service. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) < 5.0

### APIs

The Secure-cloud-run module will enable the following APIs to the Serverlesss Project:

* Google VPC Access API: `vpcaccess.googleapis.com`
* Compute API: `compute.googleapis.com`
* Container Registry API: `container.googleapis.com`
* Cloud Run API: `run.googleapis.com`

The Secure-cloud-run module will enable the following APIs to the VPC Project:

* Google VPC Access API: `vpcaccess.googleapis.com`
* Compute API: `compute.googleapis.com`

The Secure-cloud-run module will enable the following APIs to the KMS Project:

* Cloud KMS API: `cloudkms.googleapis.com`

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

* VPC Project
  * Compute Shared VPC Admin: `roles/compute.xpnAdmin`
  * Network Admin: `roles/compute.networkAdmin`
  * Security Admin: `roles/compute.securityAdmin`
  * Serverless VPC Access Admin: `roles/vpcaccess.admin`
* KMS Project
  * Cloud KMS Admin: `roles/cloudkms.admin`
* Serverless Project
  * Security Admin: `roles/compute.securityAdmin`
  * Serverless VPC Access Admin: `roles/vpcaccess.admin`
  * Cloud Run Developer: `roles/run.developer`
  * Compute Network User: `roles/compute.networkUser`
  * Artifact Registry Reader: `roles/artifactregistry.reader`

**Note:** [Secret Manager Secret Accessor](https://cloud.google.com/run/docs/configuring/secrets#access-secret) role must be granted to the Cloud Run service account to allow read access on the secret.
