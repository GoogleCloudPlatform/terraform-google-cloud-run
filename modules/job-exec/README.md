# Cloud Run Job

## Description
### tagline
Deploy a Cloud Run Job and execute it.

### detailed
This module was deploys a Cloud Run Job run and executes it.

## Usage

Basic usage of this module is as follows:

```hcl
```hcl
module "cloud_run_core" {
  source = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-run-core"
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
| container\_command | Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten | `list(string)` | `[]` | no |
| env\_secret\_vars | [Beta] Environment variables (Secret Manager) | <pre>list(object({<br>    name = string<br>    value_from = set(object({<br>      secret_key_ref = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| env\_vars | Environment variables (cleartext) | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| exec | Whether to execute job after creation | `bool` | `false` | no |
| image | GCR hosted image URL to deploy | `string` | n/a | yes |
| location | Cloud Run job deployment location | `string` | n/a | yes |
| name | The name of the Cloud Run job to create | `string` | n/a | yes |
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| service\_account\_email | Service Account email needed for the job | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Cloud Run Job ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
