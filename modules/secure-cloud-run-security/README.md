# Secure Cloud Run Security

This module handles the basic deployment security configurations for Cloud Run usage.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates KMS Keyring and Key for [customer managed encryption keys](https://cloud.google.com/run/docs/securing/using-cmek) in the **KMS Project**
to be used by Cloud Run.
* Enables Organization Policies related to Cloud Run in the **Serverless Project**.
  * Allow Ingress only from internal and Cloud Load Balancing.
  * Allow VPC Egress to Private Ranges Only.

## Usage

```hcl
module "cloud_run_security" {
  source = "../secure-cloud-run-security"

  kms_project_id        = <KMS PROJECT ID>
  location              = <KMS LOCATION>
  serverless_project_id = <SERVERLESS PROJECT ID>
  key_name              = <KEY NAME>
  keyring_name          = <KEYRING NAME>
  key_rotation_period   = <KEY ROTATION PERIOD>
  key_protection_level  = <KEY PROTECTION LEVEL>

  encrypters = [
    "serviceAccount:<SERVERLESS IDENTITY EMAIL>",
    "serviceAccount:<CLOUD RUN SERVICE ACCOUNT>"
  ]

  decrypters = [
    "serviceAccount:<SERVERLESS IDENTITY EMAIL>",
    "serviceAccount:<CLOUD RUN SERVICE ACCOUNT>"
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| decrypters | List of comma-separated owners for each key declared in set\_decrypters\_for. | `list(string)` | `[]` | no |
| encrypters | List of comma-separated owners for each key declared in set\_encrypters\_for. | `list(string)` | `[]` | no |
| folder\_id | The folder ID to apply the policy to. | `string` | `""` | no |
| key\_name | Key name. | `string` | n/a | yes |
| key\_protection\_level | The protection level to use when creating a version based on this template. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| key\_rotation\_period | Period of key rotation in seconds. | `string` | `"2592000s"` | no |
| keyring\_name | Keyring name. | `string` | n/a | yes |
| kms\_project\_id | The project where KMS will be created. | `string` | n/a | yes |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| organization\_id | The organization ID to apply the policy to. | `string` | `""` | no |
| owners | List of comma-separated owners for each key declared in set\_owners\_for. | `list(string)` | `[]` | no |
| policy\_for | Policy Root: set one of the following values to determine where the policy is applied. Possible values: ["project", "folder", "organization"]. | `string` | `"project"` | no |
| prevent\_destroy | Set the prevent\_destroy lifecycle attribute on keys.. | `bool` | `true` | no |
| serverless\_project\_id | The project where Cloud Run is going to be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| key\_self\_link | Key self link. |
| keyring\_resource | Keyring resource. |
| keyring\_self\_link | Self link of the keyring. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) < 5.0

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

* KMS Project
  * Google Cloud Key Management Service: `cloudkms.googleapis.com`

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

* KMS Project
  * Cloud KMS Admin: `roles/cloudkms.admin`
* Serverless Project
  * Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
