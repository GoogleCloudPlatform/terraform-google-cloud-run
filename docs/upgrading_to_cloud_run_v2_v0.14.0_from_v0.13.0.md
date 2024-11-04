# Upgrading to cloud-run v2 v0.14.0 from v0.13.0

The cloud-run/v2 release v0.13.0 is backward incompatible.

## Google Cloud Provider Project deletion_policy

The `deletion_policy` for projects now defaults to `"PREVENT"` rather than `"DELETE"`.
The `deletion_protection` for folders now defaults to `true` rather than `false`.
This aligns with the behavior in Google Cloud Platform Provider v6+.
To maintain the old behavior set `project_deletion_policy = "DELETE"` in the modules that create projects: `service-project-factory` and `secure-serverless-harness` and set `folder_deletion_protection = false` in the module that creates folders `secure-serverless-harness`.

```diff
  module "secure-serverless-harness" {
-   version          = "~> 0.13.0"
+   version          = "~> 0.14.0"

+   project_deletion_policy    = "DELETE"
+   folder_deletion_protection = false
}
```
