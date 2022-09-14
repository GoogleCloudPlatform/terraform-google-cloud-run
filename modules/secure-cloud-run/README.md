# Secure Cloud Run

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| artifact\_registry\_repository\_location | Artifact Registry Repository location to grant serverless identity viewer role. | `string` | n/a | yes |
| artifact\_registry\_repository\_name | Artifact Registry Repository name to grant serverless identity viewer role | `string` | n/a | yes |
| artifact\_registry\_repository\_project\_id | Artifact Registry Repository Project ID to grant serverless identity viewer role. | `string` | n/a | yes |
| cloud\_run\_sa | Service account to be used on Cloud Run. | `string` | n/a | yes |
| connector\_name | The name for the connector to be created. | `string` | `"serverless-vpc-connector"` | no |
| create\_subnet | The subnet will be created with the subnet\_name variable if true. When false, it will use the subnet\_name for the subnet. | `bool` | `true` | no |
| domain | Domain name to run the load balancer on. Used if `ssl` is `true`. Modify the default value below for your `domain` name. | `string` | n/a | yes |
| env\_vars | Environment variables (cleartext) | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| folder\_id | The folder ID to apply the policy to. | `string` | `""` | no |
| image | Image url to be deployed on Cloud Run. | `string` | n/a | yes |
| ip\_cidr\_range | The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, 10.0.0.0/8 or 192.168.0.0/16. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported | `string` | n/a | yes |
| key\_name | The name of KMS Key to be created and used in Cloud Run. | `string` | `"cloud-run-kms-key"` | no |
| key\_protection\_level | The protection level to use when creating a version based on this template. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| key\_rotation\_period | Period of key rotation in seconds. | `string` | `"2592000s"` | no |
| keyring\_name | Keyring name. | `string` | `"cloud-run-kms-keyring"` | no |
| kms\_project\_id | The project where KMS will be created. | `string` | n/a | yes |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| members | Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users.` | `list(string)` | `[]` | no |
| organization\_id | The organization ID to apply the policy to. | `string` | `""` | no |
| policy\_for | Policy Root: set one of the following values to determine where the policy is applied. Possible values: ["project", "folder", "organization"]. | `string` | `"project"` | no |
| prevent\_destroy | Set the `prevent_destroy` lifecycle attribute on the Cloud KMS key. | `bool` | `true` | no |
| region | Location for load balancer and Cloud Run resources. | `string` | n/a | yes |
| serverless\_project\_id | The project to deploy the cloud run service. | `string` | n/a | yes |
| service\_name | Shared VPC name. | `string` | n/a | yes |
| shared\_vpc\_name | Shared VPC name which is going to be re-used to create Serverless Connector. | `string` | n/a | yes |
| subnet\_name | Subnet name to be re-used to create Serverless Connector. | `string` | `null` | no |
| use\_artifact\_registry\_image | When true it will give permission to read an image from your artifact registry. | `bool` | `false` | no |
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
