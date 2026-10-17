resource "azurerm_virtual_network" "netbird" {
  name                = "vnet-${local.name_suffix}"
  location            = azurerm_resource_group.netbird.location
  resource_group_name = azurerm_resource_group.netbird.name
  address_space       = ["10.20.0.0/16"]
  tags                = local.tags
}
