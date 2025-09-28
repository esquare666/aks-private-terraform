terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #   version = "4.42.0", it will take latest version if the version not specified
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  backend "azurerm" {
    resource_group_name  = "nz3es-tfstate"
    storage_account_name = "nz3estfstate"
    container_name       = "tfstate"
    key                  = "aks.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.nz3es_subscription_paygo
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  features { #https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
    resource_group {
      prevent_deletion_if_contains_resources = false # Default is true (all Resources within the Resource Group must be deleted prior to deleting the Resource Group)
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azurerm" {
  alias = "learning"
  features {}
  subscription_id = var.learning_subscription
}
