# Upgrading to cloud-run v2 v0.14.0 from v0.13.0

The cloud-run/v2 release v0.14.0 is backward incompatible.

## Google Cloud Provider deletion_policy

Terraform Google Provider 6.0.0 [added a new field](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/version_6_upgrade) to prevent deletion of some resources.

### Projects

The `deletion_policy` for projects now defaults to `"PREVENT"` rather than `"DELETE"`.
This aligns with the behavior in Google Cloud Platform Provider v6+.
To maintain the old behavior set `project_deletion_policy = "DELETE"` in the modules [service-project-factory](../modules/service-project-factory/) and [secure-serverless-harness](../modules/secure-serverless-harness/README.md)

```diff
  module "secure-serverless-harness" {
-   version          = "~> 0.13.0"
+   version          = "~> 0.14.0"

+   project_deletion_policy    = "DELETE"
}
```

### Folder

The `deletion_protection` for folders was added and defaults to `true`.
This aligns with the behavior in Google Cloud Platform Provider v6+.
To maintain the old behavior set `folder_deletion_protection = false` in the module [secure-serverless-harness](../modules/secure-serverless-harness/README.md).

```diff
  module "secure-serverless-harness" {
-   version          = "~> 0.13.0"
+   version          = "~> 0.14.0"

+   folder_deletion_protection = false
}
```

### Cloud Run v2 Job

The `deletion_protection` for Cloud Run v2 Jobs was added and defaults to `true`.
This aligns with the behavior in Google Cloud Platform Provider v6+.
To maintain the old behavior set `cloud_run_deletion_protection = false` in the module [job-exec](../modules/job-exec/README.md).

```diff
  module "job-exec" {
-   version          = "~> 0.13.0"
+   version          = "~> 0.14.0"

+   cloud_run_deletion_protection = false
}
```

### Cloud Run v2 Service

The `deletion_protection` for Cloud Run v2 Services was added and defaults to `true`.
This aligns with the behavior in Google Cloud Platform Provider v6+.
To maintain the old behavior set `cloud_run_deletion_protection = false` in the module [v2](../modules/v2/README.md).

```diff
  module "v2" {
-   version          = "~> 0.13.0"
+   version          = "~> 0.14.0"

+   cloud_run_deletion_protection = false
}
```
