# Secure Cloud Run Core

This module handles the basic deployment core configurations for Cloud Run module.

The resources/services/activations/deletions that this module will create/trigger are:

* Creates a Cloud Run Service.
* Adds "Secret Manager Secret Accessor" role on the Secret for the Service Account used to run Cloud Run.
* Creates a Load Balancer Service using Google-managed SSL certificates.
* Creates Cloud Armor Service only including the pre-configured rules for SQLi, XSS, LFI, RCE, RFI, Scanner Detection, Protocol Attack and Session Fixation.

## Usage

```hcl
module "cloud_run_core" {
  source = "GoogleCloudPlatform/cloud-run/google//modules/secure-cloud-run-core"
  # Locked to 0.20, allows minor updates – check for latest version
  version = "~> 0.25"

  service_name          = <SERVICE NAME>
  location              = <SERVICE LOCATION>
  region                = <REGION>
  domain                = <YOUR-DOMAIN>
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
| argument | Arguments passed to the ENTRYPOINT command, include these only if image entrypoint needs arguments. | `list(string)` | `[]` | no |
| certificate\_mode | The mode of the certificate (NONE or AUTOMATIC). | `string` | `"NONE"` | no |
| cloud\_armor\_policies\_name | Cloud Armor policy name already created in the project. If `create_cloud_armor_policies` is `false`, this variable must be provided, If `create_cloud_armor_policies` is `true`, this variable will be ignored. | `string` | `null` | no |
| cloud\_run\_sa | Service account to be used on Cloud Run. | `string` | n/a | yes |
| container\_command | Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten. | `list(string)` | `[]` | no |
| container\_concurrency | Concurrent request limits to the service. | `number` | `null` | no |
| create\_cloud\_armor\_policies | When `true`, the terraform will create the Cloud Armor policies. When `false`, the user must provide their own Cloud Armor name in `cloud_armor_policies_name`. | `bool` | `true` | no |
| default\_rules | Default rule for Cloud Armor. | <pre>map(object({<br>    action         = string<br>    priority       = string<br>    versioned_expr = string<br>    src_ip_ranges  = list(string)<br>    description    = string<br>  }))</pre> | <pre>{<br>  "default_rule": {<br>    "action": "allow",<br>    "description": "Default allow all rule",<br>    "priority": "2147483647",<br>    "src_ip_ranges": [<br>      "*"<br>    ],<br>    "versioned_expr": "SRC_IPS_V1"<br>  }<br>}</pre> | no |
| domain\_map\_annotations | Annotations to the domain map. | `map(string)` | `{}` | no |
| domain\_map\_labels | A set of key/value label pairs to assign to the Domain mapping. | `map(string)` | `{}` | no |
| encryption\_key | CMEK encryption key self-link expected in the format projects/PROJECT/locations/LOCATION/keyRings/KEY-RING/cryptoKeys/CRYPTO-KEY. | `string` | n/a | yes |
| env\_vars | Environment variables. | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| force\_override | Option to force override existing mapping. | `bool` | `false` | no |
| generate\_revision\_name | Option to enable revision name generation. | `bool` | `true` | no |
| image | GAR hosted image URL to deploy. | `string` | n/a | yes |
| lb\_name | Name for load balancer and associated resources. | `string` | `"tf-cr-lb"` | no |
| limits | Resource limits to the container. | `map(string)` | `null` | no |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| max\_scale\_instances | Sets the maximum number of container instances needed to handle all incoming requests or events from each revison from Cloud Run. For more information, access this [documentation](https://cloud.google.com/run/docs/about-instance-autoscaling). | `number` | `2` | no |
| members | Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users.` | `list(string)` | `[]` | no |
| min\_scale\_instances | Sets the minimum number of container instances needed to handle all incoming requests or events from each revison from Cloud Run. For more information, access this [documentation](https://cloud.google.com/run/docs/about-instance-autoscaling). | `number` | `1` | no |
| owasp\_rules | These are additional Cloud Armor rules for SQLi, XSS, LFI, RCE, RFI, Scannerdetection, Protocolattack and Sessionfixation (requires Cloud Armor default\_rule). | <pre>map(object({<br>    action     = string<br>    priority   = string<br>    expression = string<br>  }))</pre> | <pre>{<br>  "rule_canary": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('rce-v33-stable')",<br>    "priority": "1003"<br>  },<br>  "rule_lfi": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('lfi-v33-stable')",<br>    "priority": "1002"<br>  },<br>  "rule_protocolattack": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('protocolattack-v33-stable')",<br>    "priority": "1006"<br>  },<br>  "rule_rfi": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('rfi-v33-stable')",<br>    "priority": "1004"<br>  },<br>  "rule_scannerdetection": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('scannerdetection-v33-stable')",<br>    "priority": "1005"<br>  },<br>  "rule_sessionfixation": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('sessionfixation-v33-stable')",<br>    "priority": "1007"<br>  },<br>  "rule_sqli": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('sqli-v33-stable')",<br>    "priority": "1000"<br>  },<br>  "rule_xss": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('xss-v33-stable')",<br>    "priority": "1001"<br>  }<br>}</pre> | no |
| ports | Port which the container listens to (http1 or h2c). | <pre>object({<br>    name = string<br>    port = number<br>  })</pre> | <pre>{<br>  "name": "http1",<br>  "port": 8080<br>}</pre> | no |
| project\_id | The project where cloud run is going to be deployed. | `string` | n/a | yes |
| region | Location for load balancer and Cloud Run resources. | `string` | n/a | yes |
| requests | Resource requests to the container. | `map(string)` | `{}` | no |
| service\_labels | A set of key/value label pairs to assign to the service. | `map(string)` | `{}` | no |
| service\_name | The name of the Cloud Run service to create. | `string` | n/a | yes |
| ssl\_certificates | A object with a list of domains to auto-generate SSL certificates or a list of SSL Certificates self-links in the pattern `projects/<PROJECT-ID>/global/sslCertificates/<CERT-NAME>` to be used by Load Balancer. | <pre>object({<br>    ssl_certificates_self_links       = list(string)<br>    generate_certificates_for_domains = list(string)<br>  })</pre> | n/a | yes |
| template\_labels | A set of key/value label pairs to assign to the container metadata. | `map(string)` | `{}` | no |
| timeout\_seconds | Timeout for each request. | `number` | `120` | no |
| traffic\_split | Managing traffic routing to the service. | <pre>list(object({<br>    latest_revision = bool<br>    percent         = number<br>    revision_name   = string<br>    tag             = string<br>  }))</pre> | <pre>[<br>  {<br>    "latest_revision": true,<br>    "percent": 100,<br>    "revision_name": "v1-0-0",<br>    "tag": null<br>  }<br>]</pre> | no |
| verified\_domain\_name | List of custom Domain Name. | `list(string)` | n/a | yes |
| volume\_mounts | [Beta] Volume Mounts to be attached to the container (when using secret). | <pre>list(object({<br>    mount_path = string<br>    name       = string<br>  }))</pre> | `[]` | no |
| volumes | [Beta] Volumes needed for environment variables (when using secret). | <pre>list(object({<br>    name = string<br>    secret = set(object({<br>      secret_name = string<br>      items       = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| vpc\_connector\_id | VPC Connector id in the format projects/PROJECT/locations/LOCATION/connectors/NAME. | `string` | n/a | yes |
| vpc\_egress\_value | Sets VPC Egress firewall rule. Supported values are all-traffic, all (deprecated), and private-ranges-only. all-traffic and all provide the same functionality. all is deprecated but will continue to be supported. Prefer all-traffic. | `string` | `"private-ranges-only"` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain\_map\_id | Unique Identifier for the created domain map. |
| domain\_map\_status | Status of Domain mapping. |
| load\_balancer\_ip | IP Address used by Load Balancer. |
| revision | Deployed revision for the service. |
| service\_id | Unique Identifier for the created service. |
| service\_status | Status of the created service. |
| service\_url | The URL on which the deployed service is available. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

The following dependencies must be available:

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) plugin < 5.0

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

* Serverless Project
  * Google Cloud Run Service: `run.googleapis.com`
  * Google Compute Service: `compute.googleapis.com`

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

* Cloud Run Developer: `roles/run.developer`
* Compute Network User: `roles/compute.networkUser`
* Artifact Registry Reader: `roles/artifactregistry.reader`
