# Secure Cloud Run Network

This module handles the basic deployment network configurations for Cloud Run usage.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates Firewall rules on your **VPC Project**.
* Creates a sub network to VPC Connector usage purpose.
* Creates Serverless Connector on your **VPC Project** or **Serverless Project**. Refer the comparison below:
  * Advantages of creating connectors in the [VPC Project](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#host-project)
  * Advantages of creating connectors in the [Serverless Project](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#service-projects)
* Grant the necessary roles for Cloud Run are able to use VPC Connector on your VPC.

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.53

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

## Usage

```hcl
module "cloud_run_network" {
  source = "../secure-cloud-run-net"

  connector_name            = <CONNECTOR NAME>
  subnet_name               = <SUBNETWORK NAME>
  location                  = <SUBNETWORK LOCATION>
  vpc_project_id            = <VPC PROJECT ID>
  serverless_project_id     = <SERVERLESS PROJECT ID>
  shared_vpc_name           = <SHARED VPC NAME>
  ip_cidr_range             = <IP CIDR RANGE>
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| connector\_name | The name of the serverless connector which is going to be created. | `string` | n/a | yes |
| connector\_on\_host\_project | Connector is going to be created on the host project if true. When false, connector is going to be created on service project. For more information, access [documentation](https://cloud.google.com/run/docs/configuring/connecting-shared-vpc). | `bool` | `false` | no |
| create\_subnet | The subnet will be created with the subnet\_name variable if true. When false, it will use the subnet\_name for the subnet. | `bool` | `true` | no |
| flow\_sampling | Sampling rate of VPC flow logs. The value must be in [0,1]. Where 1.0 means all logs, 0.5 mean half of the logs and 0.0 means no logs are reported. | `number` | `1` | no |
| ip\_cidr\_range | The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, 10.0.0.0/8 or 192.168.0.0/16. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported | `string` | n/a | yes |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| resource\_names\_suffix | A suffix to concat in the end of the resources names. | `string` | `null` | no |
| serverless\_project\_id | The project where cloud run is going to be deployed. | `string` | n/a | yes |
| shared\_vpc\_name | Shared VPC name which is going to be used to create Serverless Connector. | `string` | n/a | yes |
| subnet\_name | Subnet name to be re-used to create Serverless Connector. | `string` | n/a | yes |
| vpc\_project\_id | The project where shared vpc is. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_services\_sa | Service Account for Cloud Run Service. |
| connector\_id | VPC serverless connector ID. |
| gca\_vpcaccess\_sa | Service Account for VPC Access. |
| run\_identity\_services\_sa | Service Identity to run services. |
| subnet\_name | The name of the sub-network used to create VPC Connector. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
