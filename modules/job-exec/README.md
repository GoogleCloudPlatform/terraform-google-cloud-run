# Cloud Run Job

## Description

### tagline

Deploy a Cloud Run Job and execute it.

### detailed

This module was deploys a Cloud Run Job run and executes it.

## Usage

Basic usage of this module is as follows:

```hcl
module "job-exec" {
  source = "GoogleCloudPlatform/cloud-run/google//modules/job-exec"
  version = "~> 0.3.0"

  project_id = var.project_id
  name       = "simple-job"
  location   = "us-central1"
  image      = "us-docker.pkg.dev/cloudrun/container/job"
  exec       = true
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argument | Arguments passed to the ENTRYPOINT command, include these only if image entrypoint needs arguments | `list(string)` | `[]` | no |
| cloud\_run\_deletion\_protection | This field prevents Terraform from destroying or recreating the Cloud Run v2 Jobs and Services | `bool` | `true` | no |
| container\_command | Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten | `list(string)` | `[]` | no |
| env\_secret\_vars | Environment variables (Secret Manager) | <pre>list(object({<br>    name = string<br>    value_source = set(object({<br>      secret_key_ref = object({<br>        secret  = string<br>        version = optional(string, "latest")<br>      })<br>    }))<br>  }))</pre> | `[]` | no |
| env\_vars | Environment variables (cleartext) | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| exec | Whether to execute job after creation | `bool` | `false` | no |
| image | GCR hosted image URL to deploy | `string` | n/a | yes |
| labels | A set of key/value label pairs to assign to the Cloud Run job. | `map(string)` | `{}` | no |
| launch\_stage | The launch stage. (see https://cloud.google.com/products#product-launch-stages). Defaults to GA. | `string` | `""` | no |
| limits | Resource limits to the container | <pre>object({<br>    cpu    = optional(string)<br>    memory = optional(string)<br>  })</pre> | `null` | no |
| location | Cloud Run job deployment location | `string` | n/a | yes |
| max\_retries | Number of retries allowed per Task, before marking this Task failed. | `number` | `null` | no |
| name | The name of the Cloud Run job to create | `string` | n/a | yes |
| parallelism | Specifies the maximum desired number of tasks the execution should run at given time. Must be <= taskCount. | `number` | `null` | no |
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| service\_account\_email | Service Account email needed for the job | `string` | `""` | no |
| task\_count | Specifies the desired number of tasks the execution should run. | `number` | `null` | no |
| timeout | Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers. | `string` | `"600s"` | no |
| volume\_mounts | Volume to mount into the container's filesystem. | <pre>list(object({<br>    name       = string<br>    mount_path = string<br>  }))</pre> | `[]` | no |
| volumes | A list of Volumes to make available to containers. | <pre>list(object({<br>    name = string<br>    cloud_sql_instance = object({<br>      instances = set(string)<br>    })<br>  }))</pre> | `[]` | no |
| vpc\_access | Configure this to enable your service to send traffic to a Virtual Private Cloud. Set egress to ALL\_TRAFFIC or PRIVATE\_RANGES\_ONLY. Choose a connector or network\_interfaces (for direct VPC egress). For details: https://cloud.google.com/run/docs/configuring/connecting-vpc | <pre>object({<br>    connector = optional(string)<br>    egress    = optional(string)<br>    network_interfaces = optional(object({<br>      network    = optional(string)<br>      subnetwork = optional(string)<br>      tags       = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Cloud Run Job ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
