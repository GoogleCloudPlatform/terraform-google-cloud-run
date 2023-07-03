## Deploy Cloud Run Service in 3 different regions with different configurations of cloudbuild.yaml file using Cloud Build Triggers

This guide will walk you through the steps to deploy a Cloud Run service in three different regions, each with a different configuration, using a `cloudbuild.yaml` file and Cloud Build Triggers.

## Prerequisites
* You should have a Dockerfile that defines the application's containerization.
* Ensure you have a GitHub repository set up with the code for your application and three cloudbuild.yaml file namely `cloudbuild-inference-us-east1.yaml` , `cloudbuild-inference-asia-east1.yaml` and `cloudbuild-inference-europe-west1.yaml`

## What the code does? 
* Writes cloudbuild triggers which deploys application using docker file defined in cloudbuild yaml file 
* The code creates 3 cloud run services: One in each `us-east1`, `asia-east1` and `europe-west1` 
* The service hardware requirements are defined on your cloudbuild.yaml file. 
* The cloudbuild.yaml file name should be `cloudbuild-inference-us-east1.yaml` , `cloudbuild-inference-asia-east1.yaml` and `cloudbuild-inference-europe-west1.yaml` or you can change it using `main.tf` file. If you want to see an example of cloudbuild.yaml file [here](https://github.com/kshitizregmi/chatapp) is one example. 
* The Image is build automatically when there is new push in github. 


## Usage Steps in Google Console

To provision this example, run the following from within this directory:
- Open `terraform.tfvars` and update the file with values from your environment.


```bash
terraform init
```

Validate the Terraform configuration files:

```bash
terraform validate
```

Create and save the Terraform plan to a file:

```bash
terraform plan -out=tfplan
```

The -out=tfplan option saves the plan to a file named tfplan. You can choose a different filename if desired.

Review the planned changes:

```bash
terraform show tfplan
```

This step is optional but allows you to inspect the saved plan before applying it.

Apply the Terraform changes and deploy the infrastructure:

```bash
terraform apply tfplan
```
The tfplan argument specifies the plan file to apply. Terraform will prompt you to confirm the deployment. Enter yes to proceed.

Using the -out option and providing the plan file name ensures that you have a saved plan that can be used for later reference or to apply the changes without re-planning.

Again, make sure to adjust the commands according to your specific Terraform configuration and requirements.


### Clean up

- Run `terraform destroy` to clean up your environment.

## Assumptions and Prerequisites

This example assumes that below mentioned pre-requisites are in place before consuming the example.

* All required APIs are enabled in the GCP Project.
* An Organization.
* A Billing Account.
* Cloud Build triggers region must have access to Github.



By following these steps, you can automatically build and deploy your Cloud Run services in different regions with different configurations using Cloud Build Triggers and the cloudbuild.yaml files.