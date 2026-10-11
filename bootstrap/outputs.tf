output "resource_group_name" {
  description = "Resource group holding the state storage"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account holding Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container holding the state files"
  value       = azurerm_storage_container.tfstate.name
}

# Ready-to-paste backend block for other configs (e.g. netbird-azure/).
# Change the key per config.
output "backend_config_example" {
  value = <<-EOT
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.tfstate.name}"
        storage_account_name = "${azurerm_storage_account.tfstate.name}"
        container_name       = "${azurerm_storage_container.tfstate.name}"
        key                  = "netbird-azure.tfstate"
        use_azuread_auth     = true
      }
    }
  EOT
}
