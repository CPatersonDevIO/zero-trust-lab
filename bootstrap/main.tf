locals {
  location = "uksouth"
  project  = "ztlab" # short form of zero-trust-lab, used in Azure resource names

  tags = {
    project    = "zero-trust-lab"
    component  = "tfstate"
    managed_by = "terraform"
  }
}

# Who is running this? Used to grant yourself access to the state container.
data "azurerm_client_config" "current" {}

# Random suffix so the storage account name is globally unique.
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Dedicated resource group, kept separate from the lab so destroying the lab
# can never take its own state with it.
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${local.project}-tfstate-uks"
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "st${local.project}tfstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Lock it down
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false # Entra ID only, no account keys
  default_to_oauth_authentication = true  # Portal uses Entra login too

  cross_tenant_replication_enabled = false

  # Recovery if a bad apply ever trashes the state file
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Give yourself data-plane access. Being subscription Owner is not enough on
# its own to read/write blobs with Entra auth.
resource "azurerm_role_assignment" "me_blob_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Stops the state storage being deleted by accident.
resource "azurerm_management_lock" "tfstate" {
  name       = "lock-${local.project}-tfstate-nodelete"
  scope      = azurerm_resource_group.tfstate.id
  lock_level = "CanNotDelete"
  notes      = "Holds Terraform remote state for zero-trust-lab. Do not delete."

  # Create the lock last, after everything inside the group exists.
  depends_on = [
    azurerm_storage_container.tfstate,
    azurerm_role_assignment.me_blob_contributor,
  ]
}
