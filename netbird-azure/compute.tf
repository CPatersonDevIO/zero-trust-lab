resource "azurerm_network_interface" "netbird" {
  name                = "nic-${local.name_suffix}"
  location            = azurerm_resource_group.netbird.location
  resource_group_name = azurerm_resource_group.netbird.name
  tags                = local.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.netbird.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.netbird.id
  }
}

resource "azurerm_linux_virtual_machine" "netbird" {
  name                  = "vm-${local.name_suffix}"
  location              = azurerm_resource_group.netbird.location
  resource_group_name   = azurerm_resource_group.netbird.name
  size                  = var.vm_size
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.netbird.id]
  tags                  = local.tags

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureadmin"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    name                 = "osdisk-${local.name_suffix}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    tailscale_auth_key = var.tailscale_auth_key
  }))
}
