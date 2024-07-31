# Upgrading to cloud-run v2 v0.13.0 from v0.12.0

The cloud-run/v2 release v0.13.0 is backward incompatible.

## Impact

Cloud-run resource requires a service account to be used as identity. In release v0.12.0, the default
compute service account (`<project-num>-compute@developer.gserviceaccount.com`) is used if user doesn't provide a service account.

In release v0.13.0, a new service account is created by default if user doesn't provide a service account.


```diff
module "cloud_run_v2" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/v2"
  version = "~> 0.13"

  service_name = "cloud-run-v2"
  project_id   = var.project_id
  location     = "us-central1"
  containers = [
    {
      container_image = "us-docker.pkg.dev/cloudrun/container/hello"
      container_name  = "hello-world"
    }
  ]
+ create_service_account = false
}
```

To be backward compatible, a user needs to explicitly set `create_service_account` to `false`. The dafault compute service account is used when user doesn't provide a service account and `create_service_account` is set to false.
