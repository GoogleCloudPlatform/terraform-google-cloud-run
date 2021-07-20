# Terraform Cloud Run Module

This module handles the basic deployment of containerized applications on Cloud Run, along with domain mapping and IAM policy for the service.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates a Cloud Run service with provided name and container
* Creates Domain mapping for the deployed service
* Applies Cloud Run Invoker role to members

## Assumptions and Prerequisites

This module assumes that below mentioned prerequisites are in place before consuming the module.

* All required APIs are enabled in the GCP Project
* Cloud SQL (optional)
* VPC Connector (optional)
* Environment Variables in Secret Manager (optional)

## Usage

Basic usage of this module is as follows:

```hcl
module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.1.1"

  # Required variables
  service_name           = "<SERVICE NAME>"
  project_id             = "<PROJECT ID>"
  location               = "<LOCATION>"
  image                  = "gcr.io/cloudrun/hello"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argument | Arguments passed to the ENTRYPOINT command, include these only if image entrypoint needs arguments | `list(string)` | `[]` | no |
| certificate\_mode | The mode of the certificate (NONE or AUTOMATIC) | `string` | `"NONE"` | no |
| container\_command | Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten | `list(string)` | `[]` | no |
| container\_concurrency | Concurrent request limits to the service | `number` | `0` | no |
| domain\_map\_annotations | Annotations to the domain map | `map(string)` | `{}` | no |
| domain\_map\_labels | A set of key/value label pairs to assign to the Domain mapping | `map(string)` | `{}` | no |
| env\_secret\_vars | [Beta] Environment variables (Secret Manager) | <pre>list(object({<br>    name = string<br>    value_from = set(object({<br>      secret_key_ref = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| env\_vars | Environment variables (cleartext) | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| force\_override | Option to force override existing mapping | `bool` | `false` | no |
| generate\_revision\_name | Option to enable revision name generation | `bool` | `true` | no |
| image | GCR hosted image URL to deploy | `string` | n/a | yes |
| limits | Resource limits to the container | `map(string)` | `{}` | no |
| location | Cloud Run service deployment location | `string` | n/a | yes |
| members | Users/SAs to be given invoker access to the service | `list(string)` | `[]` | no |
| ports | Port which the container listens to (http1 or h2c) | <pre>object({<br>    name = string<br>    port = number<br>  })</pre> | <pre>{<br>  "name": "http1",<br>  "port": 8080<br>}</pre> | no |
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| requests | Resource requests to the container | `map(string)` | `{}` | no |
| service\_account\_email | Service Account email needed for the service | `string` | `""` | no |
| service\_annotations | Annotations to the service. Acceptable values all, internal, internal-and-cloud-load-balancing | `map(string)` | <pre>{<br>  "run.googleapis.com/ingress": "all"<br>}</pre> | no |
| service\_labels | A set of key/value label pairs to assign to the service | `map(string)` | `{}` | no |
| service\_name | The name of the Cloud Run service to create | `string` | n/a | yes |
| template\_annotations | Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate) | `map(string)` | <pre>{<br>  "autoscaling.knative.dev/maxScale": 2,<br>  "autoscaling.knative.dev/minScale": 1,<br>  "generated-by": "terraform",<br>  "run.googleapis.com/client-name": "terraform"<br>}</pre> | no |
| template\_labels | A set of key/value label pairs to assign to the container metadata | `map(string)` | `{}` | no |
| timeout\_seconds | Timeout for each request | `number` | `120` | no |
| traffic\_split | Managing traffic routing to the service | <pre>list(object({<br>    latest_revision = bool<br>    percent         = number<br>    revision_name   = string<br>  }))</pre> | <pre>[<br>  {<br>    "latest_revision": true,<br>    "percent": 100,<br>    "revision_name": "v1-0-0"<br>  }<br>]</pre> | no |
| verified\_domain\_name | Custom Domain Name | `string` | `""` | no |
| volume\_mounts | [Beta] Volume Mounts to be attached to the container (when using secret) | <pre>list(object({<br>    mount_path = string<br>    name       = string<br>  }))</pre> | `[]` | no |
| volumes | [Beta] Volumes needed for environment variables (when using secret) | <pre>list(object({<br>    name = string<br>    secret = set(object({<br>      secret_name = string<br>      items       = map(string)<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain\_map\_id | Unique Identifier for the created domain map |
| domain\_map\_status | Status of Domain mapping |
| location | Location in which the Cloud Run service was created |
| project\_id | Google Cloud project in which the service was created |
| revision | Deployed revision for the service |
| service\_id | Unique Identifier for the created service |
| service\_name | Name of the created service |
| service\_status | Status of the created service |
| service\_url | The URL on which the deployed service is available |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software
- [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ~> v3.53+
- [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) ~>
  v3.53+

### Service Account

A service account can be used with required roles to execute this module:

- Cloud Run Admin: `roles/run.admin`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the main resource of this module:

- Google Cloud Run: `run.googleapis.com`
- Serverless VPC Access (optional): `vpcaccess.googleapis.com`
- Cloud SQL (optional): `sqladmin.googleapis.com`

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.
