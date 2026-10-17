resource "azurerm_virtual_network" "netbird" {
  name                = "vnet-${local.name_suffix}"
  location            = azurerm_resource_group.netbird.location
  resource_group_name = azurerm_resource_group.netbird.name
  address_space       = ["10.20.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "netbird" {
  name                 = "snet-${local.name_suffix}"
  resource_group_name  = azurerm_resource_group.netbird.name
  virtual_network_name = azurerm_virtual_network.netbird.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_network_security_group" "netbird" {
  name                = "nsg-${local.name_suffix}"
  location            = azurerm_resource_group.netbird.location
  resource_group_name = azurerm_resource_group.netbird.name
  tags                = local.tags

  # HTTPS: NetBird dashboard, management and signal
  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # HTTP: needed for Let's Encrypt to issue the TLS certificate
  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # STUN: lets peers discover their public address for direct connections
  security_rule {
    name                       = "allow-stun-inbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "3478"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}
  

resource "azurerm_subnet_network_security_group_association" "netbird" {
  subnet_id                 = azurerm_subnet.netbird.id
  network_security_group_id = azurerm_network_security_group.netbird.id
}

resource "azurerm_public_ip" "netbird" {
  name                = "pip-${local.name_suffix}"
  location            = azurerm_resource_group.netbird.location
  resource_group_name = azurerm_resource_group.netbird.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}
