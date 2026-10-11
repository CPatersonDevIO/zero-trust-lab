terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # No backend block on purpose. This config builds the remote state storage,
  # so its own state stays local (and is gitignored).
}

provider "azurerm" {
  features {}

  # Subscription ID comes from the ARM_SUBSCRIPTION_ID environment variable,
  # so it never ends up in the public repo.

  # Talk to blob storage using Entra ID instead of storage account keys.
  # Required because shared key access is disabled on the account below.
  storage_use_azuread = true
}
