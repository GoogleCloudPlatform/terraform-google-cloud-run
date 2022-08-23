# Secure Cloud Run Core

This module handles the basic deployment core configurations for Cloud Run module.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates a Cloud Run Service.
* Creates a Load Balancer Service using Google-managed SSL certificates.
* Creates Cloud Armor Service only including the preconfigured rules for SQLi, XSS, LFI, RCE, RFI, Scannerdetection, Protocolattack and Sessionfixation.

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.53

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

* Serverless Project
  * Google Cloud Run Service: `run.googleapis.com`

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

* Cloud Run Developer: `roles/run.developer`
* Compute Network User: `roles/compute.networkUser`
* Artifact Registry Reader: `roles/artifactregistry.reader`

## Usage

```hcl
module "cloud_run_core" {
  source = "GoogleCloudPlatform/cloud-run/google//modules/cloud_run"
  version = "~> 0.2.0"

  service_name          = <SERVICE NAME>
  location              = <SERVICE LOCATION>
  serverless_project_id = <SERVICE PROJECT ID>
  image                 = <IMAGE URL>
  cloud_run_sa          = <CLOUD RUN SERVICE ACCOUNT EMAIL>
  vpc_connector_id      = <VPC CONNECTOR ID>
  encryption_key        = <KMS KEY>
  env_vars              = <ENV VARIABLES>
  members               = <MEMBERS ALLOWED TO CALL SERVICE>
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_run\_sa | Service account to be used on Cloud Run. | `string` | n/a | yes |
| default\_rules | Default rule for Cloud Armor. | <pre>map(object({<br>    action         = string<br>    priority       = string<br>    versioned_expr = string<br>    src_ip_ranges  = list(string)<br>    description    = string<br>  }))</pre> | <pre>{<br>  "default_rule": {<br>    "action": "allow",<br>    "description": "Default allow all rule",<br>    "priority": "2147483647",<br>    "src_ip_ranges": [<br>      "*"<br>    ],<br>    "versioned_expr": "SRC_IPS_V1"<br>  }<br>}</pre> | no |
| domain | Domain name to run the load balancer on. Used if `ssl` is `true`. Modify the default value below for your `domain` name. | `string` | n/a | yes |
| encryption\_key | CMEK encryption key self-link expected in the format projects/PROJECT/locations/LOCATION/keyRings/KEY-RING/cryptoKeys/CRYPTO-KEY. | `string` | n/a | yes |
| env\_vars | Environment variables. | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| image | GAR hosted image URL to deploy. | `string` | n/a | yes |
| lb\_name | Name for load balancer and associated resources. | `string` | `"tf-cr-lb"` | no |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| members | Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users.` | `list(string)` | `[]` | no |
| owasp\_rules | These are additional Cloud Armor rules for SQLi, XSS, LFI, RCE, RFI, Scannerdetection, Protocolattack and Sessionfixation (requires Cloud Armor default\_rule). | <pre>map(object({<br>    action     = string<br>    priority   = string<br>    expression = string<br>  }))</pre> | <pre>{<br>  "rule_canary": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('rce-v33-stable')",<br>    "priority": "1003"<br>  },<br>  "rule_lfi": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('lfi-v33-stable')",<br>    "priority": "1002"<br>  },<br>  "rule_protocolattack": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('protocolattack-v33-stable')",<br>    "priority": "1006"<br>  },<br>  "rule_rfi": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('rfi-v33-stable')",<br>    "priority": "1004"<br>  },<br>  "rule_scannerdetection": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('scannerdetection-v33-stable')",<br>    "priority": "1005"<br>  },<br>  "rule_sessionfixation": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('sessionfixation-v33-stable')",<br>    "priority": "1007"<br>  },<br>  "rule_sqli": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('sqli-v33-stable')",<br>    "priority": "1000"<br>  },<br>  "rule_xss": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('xss-v33-stable')",<br>    "priority": "1001"<br>  }<br>}</pre> | no |
| project\_id | The project where cloud run is going to be deployed. | `string` | n/a | yes |
| region | Location for load balancer and Cloud Run resources. | `string` | n/a | yes |
| service\_name | The name of the Cloud Run service to create. | `string` | n/a | yes |
| ssl | Run load balancer on HTTPS and provision managed certificate with provided `domain`. | `bool` | `true` | no |
| vpc\_connector\_id | VPC Connector id in the format projects/PROJECT/locations/LOCATION/connectors/NAME. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_map\_id | Unique Identifier for the created domain map. |
| domain\_map\_status | Status of Domain mapping. |
| load-balancer-ip | IP Address used by Load Balancer. |
| revision | Deployed revision for the service. |
| service\_id | Unique Identifier for the created service. |
| service\_status | Status of the created service. |
| service\_url | The URL on which the deployed service is available. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
