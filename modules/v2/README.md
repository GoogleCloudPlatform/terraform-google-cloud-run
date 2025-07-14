# Cloud Run v2 Service

## Description

### tagline

Deploy a Cloud Run Service using v2 API

### detailed

This module was deploys a Cloud Run Service and assigns access to the members.

## Usage

Basic usage of this module is as follows:

```hcl
module "cloud_run_core" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/v2"
  version = "~> 0.11.0"

  project_id      = var.project_id
  service_name    = "hello-world-gpu"
  location        = "us-central1"
  node_selector = {
    accelerator = "nvidia-l4"
  }
  containers      = [
    {
      container_image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources = {
        limits = {
          cpu    = "4"
          memory = "16Gi"
          nvidia_gpu = "1"
        }
        cpu_idle = false
      }
    }
  ]
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| binary\_authorization | Settings for the Binary Authorization feature. | <pre>object({<br>    breakglass_justification = optional(bool) # If present, indicates to use Breakglass using this justification. If useDefault is False, then it must be empty. For more information on breakglass, [see](https://cloud.google.com/binary-authorization/docs/using-breakglass)<br>    use_default              = optional(bool) #If True, indicates to use the default project's binary authorization policy. If False, binary authorization will be disabled.<br>  })</pre> | `null` | no |
| client | Arbitrary identifier for the API client and version identifier | <pre>object({<br>    name    = optional(string, null)<br>    version = optional(string, null)<br>  })</pre> | `{}` | no |
| cloud\_run\_deletion\_protection | This field prevents Terraform from destroying or recreating the Cloud Run jobs and services | `bool` | `true` | no |
| containers | Container images for the service | <pre>list(object({<br>    container_name       = optional(string, null)<br>    container_image      = string<br>    working_dir          = optional(string, null)<br>    depends_on_container = optional(list(string), null)<br>    container_args       = optional(list(string), null)<br>    container_command    = optional(list(string), null)<br>    env_vars             = optional(map(string), {})<br>    env_secret_vars = optional(map(object({<br>      secret  = string<br>      version = string<br>    })), {})<br>    volume_mounts = optional(list(object({<br>      name       = string<br>      mount_path = string<br>    })), [])<br>    ports = optional(object({<br>      name           = optional(string, "http1")<br>      container_port = optional(number, 8080)<br>    }), {})<br>    resources = optional(object({<br>      limits = optional(object({<br>        cpu        = optional(string)<br>        memory     = optional(string)<br>        nvidia_gpu = optional(string)<br>      }))<br>      cpu_idle          = optional(bool, true)<br>      startup_cpu_boost = optional(bool, false)<br>    }), {})<br>    startup_probe = optional(object({<br>      failure_threshold     = optional(number, null)<br>      initial_delay_seconds = optional(number, null)<br>      timeout_seconds       = optional(number, null)<br>      period_seconds        = optional(number, null)<br>      http_get = optional(object({<br>        path = optional(string)<br>        port = optional(string)<br>        http_headers = optional(list(object({<br>          name  = string<br>          value = string<br>        })), [])<br>      }), null)<br>      tcp_socket = optional(object({<br>        port = optional(number)<br>      }), null)<br>      grpc = optional(object({<br>        port    = optional(number)<br>        service = optional(string)<br>      }), null)<br>    }), null)<br>    liveness_probe = optional(object({<br>      failure_threshold     = optional(number, null)<br>      initial_delay_seconds = optional(number, null)<br>      timeout_seconds       = optional(number, null)<br>      period_seconds        = optional(number, null)<br>      http_get = optional(object({<br>        path = optional(string)<br>        port = optional(string)<br>        http_headers = optional(list(object({<br>          name  = string<br>          value = string<br>        })), null)<br>      }), null)<br>      tcp_socket = optional(object({<br>        port = optional(number)<br>      }), null)<br>      grpc = optional(object({<br>        port    = optional(number)<br>        service = optional(string)<br>      }), null)<br>    }), null)<br>  }))</pre> | n/a | yes |
| create\_service\_account | Create a new service account for cloud run service | `bool` | `true` | no |
| custom\_audiences | One or more custom audiences that you want this service to support. Specify each custom audience as the full URL in a string. [Refer](https://cloud.google.com/run/docs/configuring/custom-audiences) | `list(string)` | `null` | no |
| description | Cloud Run service description. This field currently has a 512-character limit. | `string` | `null` | no |
| enable\_prometheus\_sidecar | Enable Prometheus sidecar in Cloud Run instance. | `bool` | `false` | no |
| encryption\_key | A reference to a customer managed encryption key (CMEK) to use to encrypt this container image. This is optional. | `string` | `null` | no |
| execution\_environment | The sandbox environment to host this Revision. | `string` | `"EXECUTION_ENVIRONMENT_GEN2"` | no |
| gpu\_zonal\_redundancy\_disabled | True if GPU zonal redundancy is disabled on this revision. | `bool` | `false` | no |
| iap\_members | Valid only when launch stage is set to 'BETA'. IAP is enabled automatically when users or service accounts (SAs) are provided. Use allUsers for public access, allAuthenticatedUsers for any Google-authenticated user, or specify individual users/SAs. [More info](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_cloud_run_service_iam#member/members-2) | `list(string)` | `[]` | no |
| ingress | Restricts network access to your Cloud Run service | `string` | `"INGRESS_TRAFFIC_ALL"` | no |
| launch\_stage | The launch stage as defined by Google Cloud Platform Launch Stages. Cloud Run supports ALPHA, BETA, and GA. If no value is specified, GA is assumed. | `string` | `"GA"` | no |
| location | Cloud Run service deployment location | `string` | n/a | yes |
| max\_instance\_request\_concurrency | Sets the maximum number of requests that each serving instance can receive. This is optional. | `string` | `null` | no |
| members | Users/SAs to be given invoker access to the service. Grant invoker access by specifying the users or service accounts (SAs). Use allUsers for public access, allAuthenticatedUsers for access by logged-in Google users, or provide a list of specific users/SAs. [See the complete list of available options here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam#member/members-1) | `list(string)` | `[]` | no |
| node\_selector | Node Selector describes the hardware requirements of the GPU resource. [More info](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#nested_template_node_selector). | <pre>object({<br>    accelerator = string<br>  })</pre> | `null` | no |
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| revision | The unique name for the revision. If this field is omitted, it will be automatically generated based on the Service name | `string` | `null` | no |
| service\_account | Email address of the IAM service account associated with the revision of the service | `string` | `null` | no |
| service\_account\_project\_roles | Roles to grant to the newly created cloud run SA in specified project. Should be used with create\_service\_account set to true and no input for service\_account | `list(string)` | `[]` | no |
| service\_annotations | Unstructured key value map that may be set by external tools to store and arbitrary metadata. They are not queryable and should be preserved when modifying objects. [Refer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#annotations) | `map(string)` | `{}` | no |
| service\_labels | Unstructured key value map that can be used to organize and categorize objects. For more information, visit [create and update labels for projects](https://cloud.google.com/resource-manager/docs/creating-managing-labels) or [configure labels for services](https://cloud.google.com/run/docs/configuring/labels) | `map(string)` | `{}` | no |
| service\_name | The name of the Cloud Run service to create | `string` | n/a | yes |
| service\_scaling | Bounds the number of container instances for the service | <pre>object({<br>    min_instance_count = optional(number)<br>  })</pre> | `null` | no |
| session\_affinity | Enables session affinity. For more information, [go to](https://cloud.google.com/run/docs/configuring/session-affinity) | `string` | `null` | no |
| template\_annotations | Unstructured key value map that may be set by external tools to store and arbitrary metadata. They are not queryable and should be preserved when modifying objects. [Refer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#annotations) | `map(string)` | `{}` | no |
| template\_labels | Unstructured key value map that can be used to organize and categorize objects. For more information, visit [create and update labels for projects](https://cloud.google.com/resource-manager/docs/creating-managing-labels) or [configure labels for services](https://cloud.google.com/run/docs/configuring/labels) | `map(string)` | `{}` | no |
| template\_scaling | Maximum and minimum number of instances for this Revision | <pre>object({<br>    min_instance_count = optional(number)<br>    max_instance_count = optional(number)<br>  })</pre> | `null` | no |
| timeout | Max allowed time for an instance to respond to a request. A duration in seconds with up to nine fractional digits, ending with 's' | `string` | `null` | no |
| traffic | Specifies how to distribute traffic over a collection of Revisions belonging to the Service. If traffic is empty or not provided, defaults to 100% traffic to the latest Ready Revision. | <pre>list(object({<br>    type     = optional(string, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")<br>    percent  = optional(number, 100)<br>    revision = optional(string, null)<br>    tag      = optional(string, null)<br>  }))</pre> | `[]` | no |
| volumes | Volumes needed for environment variables (when using secret) | <pre>list(object({<br>    name = string<br>    secret = optional(object({<br>      secret       = string<br>      default_mode = optional(string)<br>      items = optional(object({<br>        path    = string<br>        version = optional(string)<br>        mode    = optional(string)<br>      }))<br>    }))<br>    cloud_sql_instance = optional(object({<br>      instances = optional(list(string))<br>    }))<br>    empty_dir = optional(object({<br>      medium     = optional(string)<br>      size_limit = optional(string)<br>    }))<br>    gcs = optional(object({<br>      bucket    = string<br>      read_only = optional(string)<br>    }))<br>    nfs = optional(object({<br>      server    = string<br>      path      = string<br>      read_only = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| vpc\_access | Configure this to enable your service to send traffic to a Virtual Private Cloud. Set egress to ALL\_TRAFFIC or PRIVATE\_RANGES\_ONLY. Choose a connector or network\_interfaces (for direct VPC egress). [More info](https://cloud.google.com/run/docs/configuring/connecting-vpc) | <pre>object({<br>    connector = optional(string)<br>    egress    = optional(string)<br>    network_interfaces = optional(object({<br>      network    = optional(string)<br>      subnetwork = optional(string)<br>      tags       = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| apphub\_service\_uri | Service URI in CAIS style to be used by Apphub. |
| creator | Email address of the authenticated creator. |
| effective\_annotations | All of annotations (key/value pairs) present on the resource in GCP, including the annotations configured through Terraform, other clients and services. |
| last\_modifier | Email address of the last authenticated modifier. |
| latest\_created\_revision | Name of the last created revision. See comments in reconciling for additional information on reconciliation process in Cloud Run. |
| latest\_ready\_revision | Name of the latest revision that is serving traffic. See comments in reconciling for additional information on reconciliation process in Cloud Run. |
| location | Location in which the Cloud Run service was created |
| observed\_generation | The generation of this Service currently serving traffic. |
| project\_id | Google Cloud project in which the service was created |
| service\_account\_id | Service account id and email |
| service\_id | Unique Identifier for the created service with format projects/{{project}}/locations/{{location}}/services/{{name}} |
| service\_name | Name of the created service |
| service\_uri | The main URI in which this Service is serving traffic. |
| traffic\_statuses | Detailed status information for corresponding traffic targets. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
