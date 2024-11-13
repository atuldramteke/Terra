
# backend configuration
terraform {
  backend "azurerm" {
    resource_group_name  = ""          
    storage_account_name = ""                              
    container_name       = ""                               
    key                  = ""                
  }
}

# provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

#  Core Resources
resource "azurerm_resource_group" "rg-core" {
  name     = "rg-core-${var.environment}-cascade"
  location = var.resource_group_location
  # lifecycle {
  # prevent_destroy = true
  # }
}

resource "azurerm_virtual_network" "vnet-cascade" {
  name                 = "vnet-${var.environment}-cascade"
  address_space        = var.vnet_address_space
  location             = azurerm_resource_group.rg-core.location
  resource_group_name  = azurerm_resource_group.rg-core.name
}

resource "azurerm_subnet" "snet-iis" {
  name                 = "snet-iis-${var.environment}-cascade"
  resource_group_name  = azurerm_resource_group.rg-core.name
  virtual_network_name = azurerm_virtual_network.vnet-cascade.name
  address_prefixes     = var.snet_iis_address_prefix
}

resource "azurerm_subnet" "snet-sql" {
  name                 = "snet-sql-${var.environment}-cascade"
  resource_group_name  = azurerm_resource_group.rg-core.name
  virtual_network_name = azurerm_virtual_network.vnet-cascade.name
  address_prefixes     = var.snet_sql_address_prefix
}

resource "azurerm_subnet" "snet-db" {
  name                 = "snet-db-${var.environment}-cascade"
  resource_group_name  = azurerm_resource_group.rg-core.name
  virtual_network_name = azurerm_virtual_network.vnet-cascade.name
  address_prefixes     = var.snet_db_address_prefix
}

resource "azurerm_network_security_group" "nsg-iis" {
  name                = "nsg-iis-${var.environment}-cascade"
  location            = azurerm_resource_group.rg-core.location
  resource_group_name = azurerm_resource_group.rg-core.name

security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSQL"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg-sql" {
  name                = "nsg-sql-${var.environment}-cascade"
  location            = azurerm_resource_group.rg-core.location
  resource_group_name = azurerm_resource_group.rg-core.name

security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSQL"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg-db" {
  name                = "nsg-db-${var.environment}-cascade"
  location            = azurerm_resource_group.rg-core.location
  resource_group_name = azurerm_resource_group.rg-core.name

security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSQL"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "iis" {
  subnet_id                 = azurerm_subnet.snet-iis.id
  network_security_group_id = azurerm_network_security_group.nsg-iis.id
}

resource "azurerm_subnet_network_security_group_association" "sql" {
  subnet_id                 = azurerm_subnet.snet-sql.id
  network_security_group_id = azurerm_network_security_group.nsg-sql.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.snet-db.id
  network_security_group_id = azurerm_network_security_group.nsg-db.id
}

# Loab balancer

resource "azurerm_public_ip" "lb-ip" {
  name                = "lbip-${var.environment}-cascade"
  location            = azurerm_resource_group.rg-core.location
  resource_group_name = azurerm_resource_group.rg-core.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "lb-${var.environment}-cascade"
  location            = azurerm_resource_group.rg-core.location
  resource_group_name = azurerm_resource_group.rg-core.name
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb-ip.id
  }
}

