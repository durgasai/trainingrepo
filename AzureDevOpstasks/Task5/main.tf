provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_id = var.client_id
  client_secret = var.client_secret
  features {}
}

data "azurerm_resource_group" "azrg" {
  name = var.rgname
}

data "azurerm_log_analytics_workspace" "azworkspace" {
  name = var.workspacename
  resource_group_name = data.azurerm_resource_group.azrg.name
}

data "azurerm_storage_account" "azstore" {
  name = var.diagstore
  resource_group_name = data.azurerm_resource_group.azrg.name
}
resource "azurerm_linux_virtual_machine" "azlinuxvm" {
  admin_username = var.admin_username
  location = data.azurerm_resource_group.azrg.location
  name = var.vmname
  network_interface_ids = [azurerm_network_interface.aznic.id]
  resource_group_name = data.azurerm_resource_group.azrg.name
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
  location = data.azurerm_resource_group.azrg.location
  name = var.vnetname
  resource_group_name = data.azurerm_resource_group.azrg.name
}

resource "azurerm_subnet" "azsubnet" {
  name = var.subnetname
  resource_group_name = data.azurerm_resource_group.azrg.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes     = ["20.0.0.0/24"]
}

resource "azurerm_network_interface" "aznic" {
  location = data.azurerm_resource_group.azrg.location
  name = var.nicname
  resource_group_name = data.azurerm_resource_group.azrg.name
  ip_configuration {
    name = "${var.nicname}config"
    subnet_id = azurerm_subnet.azsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.azpip.id
  }
}

resource "azurerm_public_ip" "azpip" {
  allocation_method = "Dynamic"
  location = data.azurerm_resource_group.azrg.location
  name = "${var.vmname}pip"
  resource_group_name = data.azurerm_resource_group.azrg.name
}

resource "azurerm_virtual_machine_extension" "omsagent" {
  name                       = "OmsAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.azlinuxvm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
        {
          "workspaceId": "${data.azurerm_log_analytics_workspace.azworkspace.workspace_id}"
        }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
          {
          "workspaceKey": "${data.azurerm_log_analytics_workspace.azworkspace.primary_shared_key}"
        }
PROTECTED_SETTINGS

}

resource "azurerm_monitor_diagnostic_setting" "azdiag" {
  name = "${var.diagstore}setting"
  target_resource_id = data.azurerm_log_analytics_workspace.azworkspace.id
  storage_account_id = data.azurerm_storage_account.azstore.id
  log {
    category = "Audit"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}