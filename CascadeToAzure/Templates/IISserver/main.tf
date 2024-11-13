# IISserver/main.tf

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-cascade2azure-poc"       
    storage_account_name = "castfstate"     # Updated storage account name
    container_name       = "tfbackend"
    key                  = "iis.${var.environment}.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Retrieve core infrastructure state
data "terraform_remote_state" "core" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-cascade2azure-poc"       
    storage_account_name = "castfstate"       
    container_name       = "tfbackend"
    key                  = "core.${var.environment}.terraform.tfstate"
  }
}

# Calculate the number of new VMs to add
locals {
  existing_iis_vm_count = length(data.terraform_remote_state.core.outputs.iis_vm_ids)
  new_vm_count = var.iis_count + local.existing_iis_vm_count
}

resource "azurerm_public_ip" "iis_public_ip" {
  count               = local.new_vm_count
  name                = format("P5CASWINWEB%03d-public-ip", count.index + 1)
  location            = data.terraform_remote_state.core.outputs.rglocation
  resource_group_name = data.terraform_remote_state.core.outputs.resource-group-name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "iis_nic" {
  count               = local.new_vm_count
  name                = format("P5CASWINWEB%03d-nic", count.index + 1)
  location            = data.terraform_remote_state.core.outputs.rglocation
  resource_group_name = data.terraform_remote_state.core.outputs.resource-group-name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.core.outputs.snet-iis-id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(data.terraform_remote_state.core.outputs["subnet-iis-address_prefixes"][0], count.index + 5)
    public_ip_address_id          = azurerm_public_ip.iis_public_ip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "iis_vm" {
  count               = local.new_vm_count
  name                = format("P5CASWINWEB%03d", count.index + 1)
  location            = data.terraform_remote_state.core.outputs.rglocation
  resource_group_name = data.terraform_remote_state.core.outputs.resource-group-name
  size                = "Standard_A1_v2"
  admin_username      = var.user_name
  admin_password      = var.password

  network_interface_ids = [
    element(azurerm_network_interface.iis_nic[*].id, count.index)
  ]

  os_disk {
    name                 = format("osdisk-P5CASWINWEB%03d", count.index + 1)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
