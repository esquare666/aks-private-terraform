# aks-private-terraform
AKS Private Cluster using Terraform

# Variables
## variables.tf
- Defines what variables are available and their properties (type, description, default).
- Declaration: This file is used to declare input variables that your Terraform configuration will accept. It defines the variable's name, type (e.g., string, number, bool, list, map), and an optional description.
- Default Values: You can set default values for variables within variables.tf. If a value is not explicitly provided elsewhere, Terraform will use this default.
- Validation: You can include validation rules for variables in variables.tf to ensure that the provided values meet specific criteria

## terrafrom.tfvars
- Defines what values those variables should take for a specific execution.
- Assignment: This file is used to assign specific values to the variables declared in variables.tf (or other variable declaration files). It provides the actual data that Terraform will use during execution.
- Environment-Specific Values: You can use terraform.tfvars (or other .tfvars files, like dev.tfvars, prod.tfvars) to manage environment-specific configurations, allowing you to use the same core Terraform code across different environments by simply loading the relevant .tfvars file.
- Automatic Loading: Terraform automatically loads terraform.tfvars files (and any files named *.auto.tfvars) when running commands like terraform plan or terraform apply. You can also explicitly specify a .tfvars file using the -var-file option.

## custom.tfvars
- .tfvars files (e.g., terraform.tfvars, production.tfvars, dev.tfvars) are used to explicitly assign values to variables declared in your Terraform configuration (typically in variables.tf).
- You can specify other .tfvars files using the -var-file flag with terraform plan or terraform apply

# Initialise Variables
```shell
export TF_VAR_azure_tenant_id='xxxx-xxx-xxxx-xx-xxxxx'
export TF_VAR_nz3es_subscription_paygo='xxxx-xxx-xxxx-xx-xxxxx'
export TF_VAR_azure_client_secret='4vn8Qxxxxx-xxx-xxx'
export TF_VAR_learning_subscription='xxxx-xxx-xxxx-xx-xxxxx'
```

# Execution
```shell
terraform fmt
terraform init
terraform validate
terraform plan -var-file=learning.tfvars
terraform apply -var-file=learning.tfvars
```