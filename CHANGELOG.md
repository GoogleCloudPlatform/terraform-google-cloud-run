# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.15.1](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.15.0...v0.15.1) (2024-11-28)


### Bug Fixes

* Update alternate default for vpc_access input of modules/v2 ([#267](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/267)) ([0f6aacf](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/0f6aacf00093b874c4a810de6d149290245c2995))

## [0.15.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.14.0...v0.15.0) (2024-11-27)


### Features

* Enable Prometheus sidecar in Cloud Run v2. ([#253](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/253)) ([214aa10](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/214aa105cc51399c6721b9dd26b89c5147fa27dd))

## [0.14.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.13.0...v0.14.0) (2024-11-08)


### ⚠ BREAKING CHANGES

* upgrade modules to use provider v6 ([#257](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/257))
* **deps:** Update Terraform terraform-google-modules/kms/google to v3 ([#237](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/237))

### Bug Fixes

* **deps:** Update Terraform terraform-google-modules/kms/google to v3 ([#237](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/237)) ([543be71](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/543be717b4bacbd75895d7c67f825c7c3c89465c))
* upgrade modules to use provider v6 ([#257](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/257)) ([3312703](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/3312703a81091f25bb7c2c104c04a29620206685))
* Various fixes to volumes and volume mounts ([#213](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/213)) ([3f922b8](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/3f922b818ec522cd8dbfa6ff27999d656fb712d9))

## [0.13.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.12.0...v0.13.0) (2024-09-20)


### ⚠ BREAKING CHANGES

* Create service account as part of cloud run v2 ([#219](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/219))
* Update variable field type and defaults ([#216](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/216))

### Features

* Create service account as part of cloud run v2 ([#219](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/219)) ([f64526a](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/f64526ad32d27113a8f74b686fd4ffcd54ff618b))


### Bug Fixes

* Add connection metadata for incoming connection from GCS and fix typo in v2/main.tf ([#235](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/235)) ([d359e7e](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/d359e7ee1208b5287a1b806642a2c9027a625a09))
* Update variable field type and defaults ([#216](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/216)) ([8846d89](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/8846d892dc094ea77d6eb6b53d064f0fcd63b0cc))

## [0.12.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.11.0...v0.12.0) (2024-06-05)


### Features

* added v2 service as submodule ([#200](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/200)) ([be49330](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/be4933010e65962edf5dd38dc04291e86fde97f5))

## [0.11.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.10.0...v0.11.0) (2024-05-21)


### ⚠ BREAKING CHANGES

* **deps:** Update Terraform GoogleCloudPlatform/lb-http/google to v11 ([#201](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/201))
* **deps:** Update Terraform terraform-google-modules/project-factory/google to v15 ([#199](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/199))
* **deps:** Update Terraform terraform-google-modules/vpc-service-controls/google to v6 ([#194](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/194))
* **deps:** Update Terraform GoogleCloudPlatform/lb-http/google to v10 ([#177](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/177))
* replace random_id with random_string to increase number of possible access levels ([#191](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/191))
* **deps:** Update Terraform terraform-google-modules/vpc-service-controls/google to v5 ([#180](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/180))
* **deps:** Update Terraform terraform-google-modules/network/google to v9 ([#178](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/178))
* **deps:** Update Terraform terraform-google-modules/project-factory/google to v14 ([#179](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/179))

### Bug Fixes

* **deps:** Update Terraform GoogleCloudPlatform/lb-http/google to v10 ([#177](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/177)) ([3873fdf](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/3873fdf4d4e796687f2cfe0ada9f716c6c6beab5))
* **deps:** Update Terraform GoogleCloudPlatform/lb-http/google to v11 ([#201](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/201)) ([1063b1c](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/1063b1cb99c1a3a3022777cff07a68b2663d837a))
* **deps:** Update Terraform terraform-google-modules/network/google to v9 ([#178](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/178)) ([a391262](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/a391262fac2087f08885c9620dd7015b1899d9bd))
* **deps:** Update Terraform terraform-google-modules/project-factory/google to v14 ([#179](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/179)) ([dc0815e](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/dc0815e050255eb95873d3b1d042caa8bcb17110))
* **deps:** Update Terraform terraform-google-modules/project-factory/google to v15 ([#199](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/199)) ([9df6ef2](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/9df6ef273a9b1f5abfa0c7fe1045d25423cd9244))
* **deps:** Update Terraform terraform-google-modules/vpc-service-controls/google to v5 ([#180](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/180)) ([79ade48](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/79ade48010487ef9e38472a8fe709d38c7928e03))
* **deps:** Update Terraform terraform-google-modules/vpc-service-controls/google to v6 ([#194](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/194)) ([5b63622](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/5b63622da107e1dc33c39769ebcff7644c20795b))
* ignoring client.knative.dev/nonce changes ([#185](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/185)) ([ce6e147](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/ce6e14792158da6c592678713c8957f634a38454))
* replace random_id with random_string to increase number of possible access levels ([#191](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/191)) ([f6cd4b2](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/f6cd4b2c7e081da14dfd0fbd3cefb06b5e22873d))

## [0.10.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.9.1...v0.10.0) (2023-11-14)


### Features

* add support for liveness and readiness probes ([#101](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/101)) ([0299bfe](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/0299bfec27f2cce76e2a213d77de1a125e2b3b50))
* **job-exec:** Add support for multiple arguments ([#118](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/118)) ([301f510](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/301f5109aa88771651be59b4ba024d8bdf2b15c7))


### Bug Fixes

* **deps:** expand version constraint to Terraform Google Provider to v5 (major) ([#156](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/156)) ([7fb5ebb](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/7fb5ebb96a8b15a76536141b119f1185f072f8b5))
* remove duplicate variable key ([#154](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/154)) ([f2be3c0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/f2be3c0562a6a55b108dfdd6c870d6761c8f1968))

## [0.9.1](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.9.0...v0.9.1) (2023-07-26)


### Bug Fixes

* fix vpc connector creation in Shared VPCs ([#137](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/137)) ([5979144](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/597914420843e4086ada0d9113737eccb0e6279f))

## [0.9.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.8.0...v0.9.0) (2023-07-10)


### Features

* migrate serverless_type to service-based flag ([#131](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/131)) ([8546af0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/8546af0969653284a79a540e2998997a62178a3a))


### Bug Fixes

* adds variable to not disable APIs on destroy ([#126](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/126)) ([3faedb5](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/3faedb5c67ebbf17ff48fe92b3bf9a13ba7893d3))

## [0.8.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.7.0...v0.8.0) (2023-06-01)


### Features

* Creates variable to customize time_sleep due VPC-SC  propagation time ([#124](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/124)) ([7260a62](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/7260a62d23888f863cb97085372f47dc9916f34b))

## [0.7.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.6.0...v0.7.0) (2023-05-17)


### ⚠ BREAKING CHANGES

* adds support to multiple service projects and Shared VPC ([#115](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/115))

### Features

* adds support to multiple service projects and Shared VPC ([#115](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/115)) ([bc1b8b1](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/bc1b8b1dec3830f184b3892c9aa41de17c581b41))


### Bug Fixes

* adds extra apis variable ([#119](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/119)) ([730fd95](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/730fd95f04971c4a4ed726628028bdc8c6a8d95d))

## [0.6.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.5.0...v0.6.0) (2023-04-20)


### ⚠ BREAKING CHANGES

* changes harness module to be re-used by cloud function ([#113](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/113))
* changes net module to be serverless generic ([#112](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/112))

### Features

* changes harness module to be re-used by cloud function ([#113](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/113)) ([6d7ebe9](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/6d7ebe9b805559d1e2acf227c9bab326abfe45cc))
* changes net module to be serverless generic ([#112](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/112)) ([8e34988](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/8e34988c0138b9c3357bdec0883fe11c660f0057))

## [0.5.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.4.0...v0.5.0) (2023-04-06)


### Features

* Cloud Run Jobs sub module ([#99](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/99)) ([2a4269c](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/2a4269c9902df34df23d1b812f69a33b4b0f74db))


### Bug Fixes

* add lifecycle for operation-id on domain_map ([#109](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/109)) ([71c6f29](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/71c6f29cfd0d7e5d3c1ea7bcf30c8901f72786da))
* annotations serverside diffs ([#92](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/92)) ([af92754](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/af927547a9d86ecb3656ea0e9c5e4bfcb5f518ea))
* **deps:** update terraform terracurl to v1 ([#111](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/111)) ([dcc504e](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/dcc504ee3be249daf3df9ac99c52d5e5ffeb4093))
* dev tools to 1.10 for Go 1.18 ([#110](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/110)) ([3e11fb6](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/3e11fb66563df0d295b9311230582e28117dec5f))
* Resource readiness deadline exceeded error in secure-cloud-run ([#102](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/102)) ([541ed8d](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/541ed8d1e669d6a5f917a69a660a06b2c0f74548))

## [0.4.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.3.0...v0.4.0) (2022-12-14)


### Features

* added traffic.tag ([#87](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/87)) ([1644ac0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/1644ac0731aee45afecf60d724f6b4ff6d2ffbb1))

## [0.3.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.2.0...v0.3.0) (2022-05-17)


### Features

* add cmek support ([#33](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/33)) ([9d0a6fa](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/9d0a6faec9c3cbfd66e977514a9295abe9ea51a2))


### Bug Fixes

* Set default container limits and concurrency value ([#31](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/31)) ([3311307](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/3311307f2f77f2dc7a69d838f7e27f595a32d57c))

## [0.2.0](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.1.1...v0.2.0) (2022-02-04)


### Features

* update TPG version constraints to allow 4.0 ([#25](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/25)) ([f0a6992](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/f0a69929ca35b12662d05cafc7f5d72a269be353))

### [0.1.1](https://www.github.com/GoogleCloudPlatform/terraform-google-cloud-run/compare/v0.1.0...v0.1.1) (2021-07-21)


### Bug Fixes

* Updates to README and descriptions ([#19](https://www.github.com/GoogleCloudPlatform/terraform-google-cloud-run/issues/19)) ([a3b8682](https://www.github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/a3b8682e6fe107a52b284ce5dd7023e77fad6caa))

## 0.1.0 (2021-07-12)


### Miscellaneous Chores

* release 0.1.0 ([ca3c954](https://www.github.com/GoogleCloudPlatform/terraform-google-cloud-run/commit/ca3c95477e4ab97c94ac4495a913bfe3f1df70d2))

## [0.0.1](https://github.com/GoogleCloudPlatform/terraform-google-cloud-run/tree/v0.0.1) (2021-06-27)

### Features

* Initial commit of this module - includes basic `google_cloud_run_service` resource creation
* Includes additional resources `google_cloud_run_domain_mapping`, `google_cloud_run_service_iam_member`
* Added examples and test for simple application deployment
* Updated README
