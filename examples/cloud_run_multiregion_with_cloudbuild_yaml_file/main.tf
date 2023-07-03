locals {
  trigger_descriptions = {
    "us-east1"    = "Cloud Build trigger for cloudbuild.yaml deployment in us-east1 region"
    "asia-east1"  = "Cloud Build trigger for cloudbuild.yaml deployment in asia-east1 region"
    "europe-west1" = "Cloud Build trigger for cloudbuild.yaml deployment in europe-west1 region"
  }

  trigger_filenames = {
    "us-east1"    = "cloudbuild-inference-us-east1.yaml"
    "asia-east1"  = "cloudbuild-inference-asia-east1.yaml"
    "europe-west1" = "cloudbuild-inference-europe-west1.yaml"
  }
}

data "github_repository" "repo" {
  full_name = var.repo_name
}

locals {
  triggers = [
    for location, description in local.trigger_descriptions : {
      location     = location
      name         = "${var.application_name}-v${var.version_name}-inference-${location}-trigger"
      description  = description
      filename     = local.trigger_filenames[location]
    }
  ]
}

resource "google_cloudbuild_trigger" "app_trigger" {
  for_each = { for trigger in local.triggers : trigger.location => trigger }

  location     = each.value.location
  name         = each.value.name
  description  = each.value.description

  github {
    owner = "<user_name>"  # your github username or the organization name
    name  = "<repo_name>"       # your repo name or the organization repo name
    push {
      branch = var.branch_name
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  source_to_build {
    ref       = "refs/heads/${var.branch_name}"
    repo_type = "GITHUB"
  }

  substitutions = {
    _SHORT_SHA   = ""
    _TAG_NAME    = ""
    _REPO_NAME   = var.repo_name
    _BRANCH_NAME = var.branch_name
  }

  filename = each.value.filename
}