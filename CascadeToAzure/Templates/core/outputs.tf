# Core/outputs.tf

# IIS VM IDs output
output "iis_vm_ids" {
  value = azurerm_windows_virtual_machine.iis_vm.*.id
}

# SQL VM IDs output
output "sql_vm_ids" {
  value = azurerm_windows_virtual_machine.sql_vm.*.id
}

# Additional existing outputs
output "resource-group-id" {
  value = azurerm_resource_group.rg-core.id
}

output "resource-group-name" {
  value = azurerm_resource_group.rg-core.name
}

output "rglocation" {
  value = azurerm_resource_group.rg-core.location
}

output "snet-iis-id" {
  value = azurerm_subnet.snet-iis.id
}

output "snet-sql-id" {
  value = azurerm_subnet.snet-sql.id
}

output "subnet-iis-address_prefixes" {
  value = azurerm_subnet.snet-iis.address_prefixes
}

output "subnet-sql-address_prefixes" {
  value = azurerm_subnet.snet-sql.address_prefixes
}
