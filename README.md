# Python Azure Function Remote Build
Example repository to show how a relatively minimal Python application can be provisioned with Terraform in Azure, and 
then built and deployed remotely with a .zip file as Azure function app.

The README is written by a Linux user. Modify the examples for your platform where necessary.

## Prerequisites
The following tools should be installed and available on your terminal PATH:
- azure (az)
- terraform
- zip

Also, you should be logged in to your Azure account (`az login`) and have selected your desired Azure subscription
(see e.g. [az-account-switcher](https://github.com/abij/az-account-switcher))

## Deploy Azure resources with Terraform
Follow these steps to deploy the Azure resources with Terraform:
1. Update the default values in `terraform/variables.tf`. You can additionally check if the naming conventions used in
`main.tf` follow your (company's) style.
2. Go to the terraform folder on the command line (`{project root}/terraform/`).
3. Run `terraform init` to setup Terraform (download providers and setup initial state).
4. Run `terraform apply`.

Besides deploying the resources in Azure, the last step also creates the deployment script as
`{project root}/scripts/deploy_function_app.sh`.  

## Deploy the function app
In the previous step Terraform created the deploy script at `{project root}/scripts/deploy_function_app.sh`.
This script consists of two steps building the zip, then using the Azure cli to trigger the remote build and deployment.

The script must be run from the project root so that the path references are correct. There are many ways to run a
script on the commandline, I like:
```shell
sh scripts/deploy_function_app.sh
```

Note: in case you're extending this example application, the zip file should contain:
- all files and folders required for the 'business logic' (in this example the `app` folder)
- all functions folders (in this example there's only one function: the `function` folder)
- the `host.json` file
- the `requirements.txt` file

## Smoke test
You can perform a simple smoke-test with `curl` to check that the function is running. The command looks like this for the default values in `{project root}/terraform/variables.tf` 
```shell
curl https://dev-zipdeploy-functions.azurewebsites.net
```