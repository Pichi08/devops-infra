output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

# output "redis_hostname" {
#   description = "The hostname for the Azure Cache for Redis instance."
#   value       = azurerm_redis_cache.redis.hostname
# }
# 
# output "redis_primary_access_key" {
#   description = "The primary access key for the Azure Cache for Redis instance."
#   value       = azurerm_redis_cache.redis.primary_access_key
#   sensitive   = true
# }

output "container_app_environment_domain" {
  description = "The default domain of the Container App Environment."
  value       = azurerm_container_app_environment.cae.default_domain
}

output "frontend_fqdn" {
  description = "The fully qualified domain name (FQDN) for the frontend application."
  value       = azurerm_container_app.frontend.latest_revision_fqdn
}
