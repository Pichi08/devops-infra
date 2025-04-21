resource "azurerm_container_registry" "acr" {
  # Modified name to be potentially more unique
  name                = "${replace(var.resource_prefix, "-", "")}acrregistry" # ACR names must be alphanumeric
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = true # Enable admin user for easier authentication initially

  depends_on = [
    azurerm_resource_group.rg
  ]
}
