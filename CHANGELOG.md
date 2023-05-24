# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
