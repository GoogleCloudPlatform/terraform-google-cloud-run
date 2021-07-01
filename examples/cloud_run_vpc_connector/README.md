# Terraform Cloud Run Module

This exmaple module handles the basic deployment of containerized applications on Cloud Run, along with domain mapping and IAM policy for the service.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates a Cloud Run service with provided name and container with Serverless VPC Connector

## Assumptions and Prerequisites

This module assumes that below mentioend prerequisites are in place before consuming the module.

* All required APIs are enabled in the GCP Project
* VPC Connector

## Usage

Basic usage of this module is as follows:

```hcl
module "cloud_run_vpc_connector" {
  source = "./cloud_run_vpc_connector"

  service_name           = var.service_name
  project_id             = var.project_id
  location               = var.location
  generate_revision_name = true
  image                  = var.image
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project ID to deploy to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| connector\_id | n/a |
| revision | Deployed revision for the service |
| service\_id | Unique Identifier for the created service |
| service\_location | Location in which the Cloud Run service was created |
| service\_name | Name of the created service |
| service\_status | Status of the created service |
| service\_url | The URL on which the deployed service is available |
| subnets | n/a |
| vpc\_name | VPC created for serverless |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13+
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.53+

### Service Account

A user managed service account can be used with required roles to deploy and access other resources from Cloud Run service:

- GKE Admin: `roles/container.admin`
- Storage Admin: `roles/storage.admin`

Note: In order to deploy a service with a user-managed service account, the user deploying the service must have the `iam.serviceAccounts.actAs` permission on that service account.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Run: `run.googleapis.com`
- Serverless VPC Access: `vpcaccess.googleapis.com`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.
