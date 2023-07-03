variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "repo_name" {
  description = "The name of the connected Git repository in Cloud Source Repositories"
  type        = string
}

variable "branch_name" {
  description = "The name of the github  branch to trigger deployments"
  type        = string
}

variable "version_name" {
  description = "Model Version"
  type = string
}

variable "application_name" {
  description = "Application Name for.eg. chatapp"
  type = string
}

variable "user_name" {
  description = "Github User Name or Organization Name"
  type = string
}