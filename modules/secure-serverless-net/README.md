# Secure Serverless Network

This module handles the basic deployment network configurations for Secure Serverless usage.
When using a Shared VPC, you can chose where to create the VPC Connector.

_Note:_ When using a single VPC you should provides VPC and Serverless project id with the same value and the value for `connector_on_host_project` variable must be `false`.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates Firewall rules on your **VPC Project**.
  * Serverless to VPC Connector
  * VPC Connector to Serverless
  * VPC Connector to LB
  * VPC Connector Health Checks
* Creates a sub network to VPC Connector usage purpose.
* Creates Serverless Connector on your **VPC Project** or **Serverless Project**. Refer the comparison below:
  * Advantages of creating connectors in the [VPC Project](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#host-project)
  * Advantages of creating connectors in the [Serverless Project](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#service-projects)
* Grant the necessary roles for Cloud Run or Cloud Functions 2nd Gen be able to use VPC Connector on your Shared VPC when creating VPC Connector in host project.
  * Grant Network User role to Cloud Services service account.
  * Grant VPC Access User to Cloud Run or Cloud Functions 2nd Gen Service Identity when deploying VPC Access.

## Usage

```hcl
module "cloud_serverless_network" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-serverless-net"
  # Locked to 0.20, allows minor updates – check for latest version
  version = "~> 0.25"

  connector_name            = <CONNECTOR NAME>
  subnet_name               = <SUBNETWORK NAME>
  location                  = <SUBNETWORK LOCATION>
  vpc_project_id            = <VPC PROJECT ID>
  serverless_project_id     = <SERVERLESS PROJECT ID>
  shared_vpc_name           = <SHARED VPC NAME>
  ip_cidr_range             = <IP CIDR RANGE>

  serverless_service_identity_email = <SERVERLESS IDENTITY EMAIL>
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| connector\_name | The name of the serverless connector which is going to be created. | `string` | n/a | yes |
| connector\_on\_host\_project | Connector is going to be created on the host project if true. When false, connector is going to be created on service project. For more information, access [documentation](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc). | `bool` | `false` | no |
| create\_subnet | The subnet will be created with the subnet\_name variable if true. When false, it will use the subnet\_name for the subnet. | `bool` | `true` | no |
| enable\_load\_balancer\_fw | Create the firewall rule for Cloud Run to enable the VPC Connector to access the Load Balancer instance using TCP port 80. Default is true. If using Cloud Function set to false. | `bool` | `true` | no |
| flow\_sampling | Sampling rate of VPC flow logs. The value must be in [0,1]. Where 1.0 means all logs, 0.5 mean half of the logs and 0.0 means no logs are reported. | `number` | `1` | no |
| ip\_cidr\_range | The range of internal addresses that are owned by the subnetwork and which is going to be used by VPC Connector. For example, 10.0.0.0/28 or 192.168.0.0/28. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported. | `string` | n/a | yes |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| resource\_names\_suffix | A suffix to concat in the end of the resources names. | `string` | `null` | no |
| serverless\_project\_id | The project where Secure Serverless is going to be deployed. | `string` | n/a | yes |
| serverless\_service\_identity\_email | The Service Identity email for the serverless resource (Cloud Run or Cloud Function). | `string` | n/a | yes |
| shared\_vpc\_name | Shared VPC name which is going to be used to create Serverless Connector. | `string` | n/a | yes |
| subnet\_name | Subnet name to be re-used to create Serverless Connector. | `string` | n/a | yes |
| vpc\_project\_id | The project where shared vpc is. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_services\_sa | Google APIs service agent. |
| connector\_id | VPC serverless connector ID. |
| gca\_vpcaccess\_sa | Google APIs Service Agent for VPC Access. |
| subnet\_name | The name of the sub-network used to create VPC Connector. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) plugin < 5.0

### APIs

The Serverless and Network project with the following APIs enabled must be used to host the
resources of this module:

* Google VPC Access API: `vpcaccess.googleapis.com`
* Compute API: `compute.googleapis.com`

### Service Account

A service account with one of the following roles must be used to provision
the resources of this module:

* Network Project
  * Compute Shared VPC Admin: `roles/compute.xpnAdmin`
  * Network Admin: `roles/compute.networkAdmin`
  * Security Admin: `roles/compute.securityAdmin`
  * Serverless VPC Access Admin: `roles/vpcaccess.admin`
* Serverless Project
  * Security Admin: `roles/compute.securityAdmin`
  * Serverless VPC Access Admin: `roles/vpcaccess.admin`
