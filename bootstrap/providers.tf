terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
  }

  # This config created the remote state storage. It was first applied with
  # local state, then its own state was migrated into the storage it built.
  backend "azurerm" {
    resource_group_name  = "rg-ztlab-tfstate-uks"
    storage_account_name = "stztlabtfstatemxojs8"
    container_name       = "tfstate"
    key                  = "bootstrap.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}

  # Subscription ID comes from the ARM_SUBSCRIPTION_ID environment variable,
  # so it never ends up in the public repo.

  # Talk to blob storage using Entra ID instead of storage account keys.
  # Required because shared key access is disabled on the account.
  storage_use_azuread = true
}