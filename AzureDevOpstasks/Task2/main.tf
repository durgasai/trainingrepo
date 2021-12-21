provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_id = var.client_id
  client_secret = var.client_secret
  features {}
}

resource "azurerm_linux_virtual_machine" "azlinuxvm" {
  admin_username = var.admin_username
  location = azurerm_resource_group.azrg.location
  name = var.vmname
  network_interface_ids = [azurerm_network_interface.aznic.id]
  resource_group_name = azurerm_resource_group.azrg.name
  size = "Standard_DS1_v2"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  disable_password_authentication = "false"
  admin_password = var.admin_password
}

resource "azurerm_virtual_network" "azvnet" {
  address_space = ["20.0.0.0/16"]
  location = azurerm_resource_group.azrg.location
  name = var.vnetname
  resource_group_name = azurerm_resource_group.azrg.name
}

resource "azurerm_subnet" "azsubnet" {
  name = var.subnetname
  resource_group_name = azurerm_resource_group.azrg.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes     = ["20.0.0.0/24"]
}

resource "azurerm_network_interface" "aznic" {
  location = azurerm_resource_group.azrg.location
  name = var.nicname
  resource_group_name = azurerm_resource_group.azrg.name
  ip_configuration {
    name = "${var.nicname}config"
    subnet_id = azurerm_subnet.azsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.azpip.id
  }
}

resource "azurerm_resource_group" "azrg" {
  location = var.location
  name = var.rgname
}

resource "azurerm_public_ip" "azpip" {
  allocation_method = "Dynamic"
  location = azurerm_resource_group.azrg.location
  name = "${var.vmname}pip"
  resource_group_name = azurerm_resource_group.azrg.name
}