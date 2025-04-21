# resource "azurerm_redis_cache" "redis" {
#   name                = "${var.resource_prefix}-redis"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   capacity            = var.redis_capacity
#   family              = var.redis_family
#   sku_name            = var.redis_sku_name
#   non_ssl_port_enabled = false # Renamed from enable_non_ssl_port
#   minimum_tls_version = "1.2"
# }
