# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
