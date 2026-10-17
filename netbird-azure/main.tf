resource "azurerm_resource_group" "netbird" {
  name     = "rg-${local.name_suffix}" # rg-ztlab-netbird-uks
  location = local.location
  tags     = local.tags
}
