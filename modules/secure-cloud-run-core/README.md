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
  version = "~> 0.24"

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
| argument | Arguments passed to the ENTRYPOINT command. | `list(string)` | `[]` | no |
| certificate\_mode | The mode of the certificate (NONE or AUTOMATIC). | `string` | `"NONE"` | no |
| cloud\_armor\_policies\_name | Existing Cloud Armor policy name if create\_cloud\_armor\_policies is false. | `string` | `null` | no |
| cloud\_run\_deletion\_protection | This field prevents Terraform from destroying or recreating the Cloud Run v2 Jobs and Services | `bool` | `false` | no |
| cloud\_run\_sa | Service account to be used on Cloud Run. | `string` | n/a | yes |
| container\_command | Container entrypoint command. | `list(string)` | `[]` | no |
| container\_concurrency | Concurrent request limits to the service. | `number` | `null` | no |
| create\_cloud\_armor\_policies | When true, create Cloud Armor policies. When false, provide existing name. | `bool` | `true` | no |
| default\_rules | Default rule for Cloud Armor. | <pre>map(object({<br>    action         = string<br>    priority       = string<br>    versioned_expr = string<br>    src_ip_ranges  = list(string)<br>    description    = string<br>  }))</pre> | <pre>{<br>  "default_rule": {<br>    "action": "allow",<br>    "description": "Default allow all rule",<br>    "priority": "2147483647",<br>    "src_ip_ranges": [<br>      "*"<br>    ],<br>    "versioned_expr": "SRC_IPS_V1"<br>  }<br>}</pre> | no |
| domain\_map\_annotations | Annotations to the domain map. | `map(string)` | `{}` | no |
| domain\_map\_labels | Labels to assign to the Domain mapping. | `map(string)` | `{}` | no |
| enable\_prometheus\_sidecar | Enable Prometheus sidecar in Cloud Run instance. | `bool` | `false` | no |
| encryption\_key | CMEK encryption key self-link. | `string` | `null` | no |
| env\_vars | Environment variables. | <pre>list(object({<br>    value = string<br>    name  = string<br>  }))</pre> | `[]` | no |
| execution\_environment | The execution environment (e.g., EXECUTION\_ENVIRONMENT\_GEN2, EXECUTION\_ENVIRONMENT\_GEN1). | `string` | `"EXECUTION_ENVIRONMENT_GEN2"` | no |
| force\_override | Option to force override existing mapping. | `bool` | `false` | no |
| generate\_revision\_name | Option to enable revision name generation. | `bool` | `true` | no |
| gpu\_zonal\_redundancy\_disabled | True if GPU zonal redundancy is disabled on this revision. | `bool` | `false` | no |
| iap\_members | Users/SAs to be given IAP access (if IAP is enabled). | `list(string)` | `[]` | no |
| image | GAR hosted image URL to deploy. | `string` | n/a | yes |
| ingress | Ingress traffic sources allowed to call the service. | `string` | `"INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"` | no |
| launch\_stage | The launch stage as defined by Google Cloud Platform Launch Stages. Cloud Run supports ALPHA, BETA, and GA. If no value is specified, GA is assumed. | `string` | `"GA"` | no |
| lb\_name | Name for load balancer and associated resources. | `string` | `"tf-cr-lb"` | no |
| limits | Resource limits (memory, cpu, nvidia.com/gpu). | `map(string)` | `null` | no |
| liveness\_probe | Configuration for the liveness probe. | <pre>object({<br>    failure_threshold     = optional(number)<br>    initial_delay_seconds = optional(number)<br>    timeout_seconds       = optional(number)<br>    period_seconds        = optional(number)<br>    http_get = optional(object({<br>      path = optional(string)<br>      port = optional(number)<br>      http_headers = optional(list(object({<br>        name  = string<br>        value = string<br>      })))<br>    }))<br>    tcp_socket = optional(object({<br>      port = number<br>    }))<br>    grpc = optional(object({<br>      port    = optional(number)<br>      service = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| location | The location where resources are going to be deployed. | `string` | n/a | yes |
| max\_scale\_instances | Maximum number of container instances. | `number` | `100` | no |
| members | Users/SAs to be given invoker access. | `list(string)` | `[]` | no |
| min\_scale\_instances | Minimum number of container instances. | `number` | `0` | no |
| node\_selector | Node Selector describes the hardware requirements of the GPU resource. [More info](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#nested_template_node_selector). | <pre>object({<br>    accelerator = string<br>  })</pre> | `null` | no |
| owasp\_rules | Additional Cloud Armor rules (SQLi, XSS, etc). | <pre>map(object({<br>    action     = string<br>    priority   = string<br>    expression = string<br>  }))</pre> | <pre>{<br>  "rule_canary": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('rce-v33-stable')",<br>    "priority": "1003"<br>  },<br>  "rule_lfi": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('lfi-v33-stable')",<br>    "priority": "1002"<br>  },<br>  "rule_protocolattack": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('protocolattack-v33-stable')",<br>    "priority": "1006"<br>  },<br>  "rule_rfi": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('rfi-v33-stable')",<br>    "priority": "1004"<br>  },<br>  "rule_scannerdetection": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('scannerdetection-v33-stable')",<br>    "priority": "1005"<br>  },<br>  "rule_sessionfixation": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('sessionfixation-v33-stable')",<br>    "priority": "1007"<br>  },<br>  "rule_sqli": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('sqli-v33-stable')",<br>    "priority": "1000"<br>  },<br>  "rule_xss": {<br>    "action": "deny(403)",<br>    "expression": "evaluatePreconfiguredExpr('xss-v33-stable')",<br>    "priority": "1001"<br>  }<br>}</pre> | no |
| ports | Port which the container listens to. | <pre>object({<br>    name = string<br>    port = number<br>  })</pre> | <pre>{<br>  "name": "http1",<br>  "port": 8080<br>}</pre> | no |
| project\_id | The project where cloud run is going to be deployed. | `string` | n/a | yes |
| region | Location for load balancer and Cloud Run resources (usually same as location). | `string` | n/a | yes |
| requests | Resource requests (memory, cpu). Note: Child module must be patched to support this field. | `map(string)` | `{}` | no |
| service\_labels | Labels to assign to the service. | `map(string)` | `{}` | no |
| service\_name | The name of the Cloud Run service to create. | `string` | n/a | yes |
| ssl\_certificates | A object with a list of domains to auto-generate SSL certificates or a list of SSL Certificates self-links. | <pre>object({<br>    ssl_certificates_self_links       = list(string)<br>    generate_certificates_for_domains = list(string)<br>  })</pre> | n/a | yes |
| startup\_probe | Configuration for the startup probe. | <pre>object({<br>    failure_threshold     = optional(number)<br>    initial_delay_seconds = optional(number)<br>    timeout_seconds       = optional(number)<br>    period_seconds        = optional(number)<br>    http_get = optional(object({<br>      path = optional(string)<br>      port = optional(number)<br>      http_headers = optional(list(object({<br>        name  = string<br>        value = string<br>      })))<br>    }))<br>    tcp_socket = optional(object({<br>      port = number<br>    }))<br>    grpc = optional(object({<br>      port    = optional(number)<br>      service = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| template\_labels | Labels to assign to the container metadata. | `map(string)` | `{}` | no |
| timeout\_seconds | Timeout for each request in seconds. | `number` | `120` | no |
| traffic\_split | Managing traffic routing to the service. | <pre>list(object({<br>    latest_revision = optional(bool)<br>    percent         = number<br>    revision_name   = optional(string)<br>    tag             = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "latest_revision": true,<br>    "percent": 100<br>  }<br>]</pre> | no |
| verified\_domain\_name | List of custom Domain Name. | `list(string)` | `[]` | no |
| volume\_mounts | Volume Mounts to be attached to the container. | <pre>list(object({<br>    mount_path = string<br>    name       = string<br>  }))</pre> | `[]` | no |
| volumes | [Beta] Volumes needed for environment variables (when using secret). | <pre>list(object({<br>    name = string<br>    secret = set(object({<br>      secret_name = string<br>      items       = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| vpc\_connector\_id | VPC Connector id. If provided, Direct VPC Egress settings are ignored. | `string` | `null` | no |
| vpc\_egress\_value | Sets VPC Egress firewall rule (e.g. PRIVATE\_RANGES\_ONLY, ALL\_TRAFFIC). | `string` | `"PRIVATE_RANGES_ONLY"` | no |
| vpc\_network\_interface | List of network interfaces for Direct VPC Egress (Cloud Run v2). | <pre>object({<br>    network    = optional(string)<br>    subnetwork = optional(string)<br>    tags       = optional(list(string))<br>  })</pre> | `null` | no |

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
