# Upgrading to v7.0

The v7.0 release contains backwards-incompatible
changes due to renaming the sub-modules name.

## secure-serverless-net

The module was rename from `secure-cloud-serverless-net` to `secure-serverless-net`.
The required variable`serverless_type` was also added to allow re-use from Cloud Functions (2nd Gen).

```diff
module "cloud_run_network" {
-  source = "../secure-cloud-serverless-net"
+  source = "../secure-serverless-net"

   connector_name            = var.connector_name
   subnet_name               = var.subnet_name
   location                  = var.location
   vpc_project_id            = var.vpc_project_id
   serverless_project_id     = var.serverless_project_id
   shared_vpc_name           = var.shared_vpc_name
   connector_on_host_project = false
   ip_cidr_range             = var.ip_cidr_range
   create_subnet             = var.create_subnet
   resource_names_suffix     = var.resource_names_suffix
+  serverless_type           = "CLOUD_RUN"
   serverless_service_identity_email = google_project_service_identity.serverless_sa.email
}
```

## secure-serverless-harness

The module was rename from `secure-cloud-serverless-harness` to `secure-serverless-harness`.
The`serverless_project_name` variable was changed to accept more than one name, to create
one or more service projects.

```diff
module "secure_harness" {
-  source                                      = "../../modules/secure-cloud-serverless-harness"
+  source                                      = "../../modules/secure-serverless-harness"
   billing_account                             = var.billing_account
   security_project_name                       = "prj-kms-secure-cloud-run"
-  serverless_project_name                     = "prj-secure-cloud-run"
+  serverless_project_names                    = ["prj-secure-cloud-run"]
   org_id                                      = var.org_id
   parent_folder_id                            = var.parent_folder_id
   serverless_folder_suffix                    = random_id.random_folder_suffix.hex
   serverless_service_identity_email           = google_project_service_identity.serverless_sa.email
   region                                      = local.region
   location                                    = local.location
   vpc_name                                    = "vpc-secure-cloud-run"
   subnet_ip                                   = "10.0.0.0/28"
   private_service_connect_ip                  = "10.3.0.5"
   create_access_context_manager_access_policy = var.create_access_context_manager_access_policy
   access_context_manager_policy_id            = var.access_context_manager_policy_id
   access_level_members                        = var.access_level_members
   key_name                                    = "key-secure-artifact-registry"
   keyring_name                                = "krg-secure-artifact-registry"
   prevent_destroy                             = false
   artifact_registry_repository_name           = local.repository_name
   egress_policies                             = var.egress_policies
   ingress_policies                            = var.ingress_policies
   serverless_type                             = "CLOUD_RUN"
```
