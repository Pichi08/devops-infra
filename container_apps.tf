resource "azurerm_log_analytics_workspace" "la" {
  name                = "${var.resource_prefix}-logs"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_container_app_environment" "cae" {
  name                       = "${var.resource_prefix}-cae"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
}

# --- Container App Definitions ---

resource "azurerm_container_app" "frontend" {
  name                         = "${var.resource_prefix}-frontend-ca"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      # TEMPORARY: Using placeholder image until actual image is pushed
      image  = "${azurerm_container_registry.acr.login_server}/frontend:latest" # Original image
      cpu    = 0.25
      memory = "0.5Gi"
    }
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true # External access for frontend
    target_port      = 8080 # Port from frontend Dockerfile
    transport        = "http"
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password" # Will create secret below
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }
}

resource "azurerm_container_app" "auth_api" {
  name                         = "${var.resource_prefix}-auth-api-ca"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "auth-api"
      # TEMPORARY: Using placeholder image until actual image is pushed
      image  = "${azurerm_container_registry.acr.login_server}/auth-api:latest" # Original image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "AUTH_API_PORT"
        value = "8000"
      }
      env {
        name = "USERS_API_ADDRESS"
        # Internal FQDN will be constructed like: http://<app-name>.<environment-name>.<region>.azurecontainerapps.io
        # Using placeholder - ideally use Key Vault or app config later
        value = "http://${azurerm_container_app.users_api.name}.${azurerm_container_app_environment.cae.default_domain}"
      }
      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret" # Placeholder for secret
      }
      # Add ZIPKIN_URL if needed
    }
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = false # Internal only
    target_port      = 8000  # Port from auth-api Dockerfile
    transport        = "http"
    # Allow traffic from frontend and potentially other internal services
    allow_insecure_connections = true # Required for http within environment
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }
  secret {
    name  = "jwt-secret"
    value = "change-this-super-secret-jwt-key" # Replace with a secure way to manage secrets (e.g., Key Vault reference)
  }

  # Depends on users_api being available for the FQDN
  depends_on = [azurerm_container_app.users_api]
}

resource "azurerm_container_app" "todos_api" {
  name                         = "${var.resource_prefix}-todos-api-ca"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "todos-api"
      # TEMPORARY: Using placeholder image until actual image is pushed
      image  = "${azurerm_container_registry.acr.login_server}/todos-api:latest" # Original image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "TODO_API_PORT"
        value = "8082"
      }
      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret"
      }
      # env {
      #   name        = "REDIS_HOST"
      #   value       = azurerm_redis_cache.redis.hostname
      # }
      # env {
      #   name        = "REDIS_PORT"
      #   value       = azurerm_redis_cache.redis.ssl_port # Use SSL port
      # }
      #  env {
      #   name        = "REDIS_PASSWORD"
      #   secret_name = "redis-password"
      # }
      # env {
      #   name  = "REDIS_CHANNEL"
      #   value = "log_channel" # Or make this configurable
      # }
      # Add ZIPKIN_URL if needed
    }
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = false # Internal only
    target_port      = 8082  # Port from todos-api Dockerfile
    transport        = "http"
    allow_insecure_connections = true
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }
  secret {
    name  = "jwt-secret"
    value = "change-this-super-secret-jwt-key" # Use same placeholder or Key Vault ref
  }
  #  secret {
  #   name  = "redis-password"
  #   value = azurerm_redis_cache.redis.primary_access_key
  # }
}

resource "azurerm_container_app" "users_api" {
  name                         = "${var.resource_prefix}-users-api-ca"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "users-api"
      # TEMPORARY: Using placeholder image until actual image is pushed
      image  = "${azurerm_container_registry.acr.login_server}/users-api:latest" # Original image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "SERVER_PORT"
        value = "8083"
      }
      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret"
      }
      # Add DB connection details if needed (likely requires secrets)
    }
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = false # Internal only
    target_port      = 8083  # Port from users-api Dockerfile
    transport        = "http"
    allow_insecure_connections = true
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }
  secret {
    name  = "jwt-secret"
    value = "change-this-super-secret-jwt-key" # Use same placeholder or Key Vault ref
  }
}

resource "azurerm_container_app" "log_processor" {
  name                         = "${var.resource_prefix}-log-processor-ca"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  # workload_profile_name        = "Consumption" # Removed: Cannot specify for Consumption Only environment

  template {
    container {
      name   = "log-message-processor"
      # TEMPORARY: Using placeholder image until actual image is pushed
      image  = "${azurerm_container_registry.acr.login_server}/log-message-processor:latest" # Original image
      cpu    = 0.25
      memory = "0.5Gi"

      # env {
      #   name        = "REDIS_HOST"
      #   value       = azurerm_redis_cache.redis.hostname
      # }
      # env {
      #   name        = "REDIS_PORT"
      #   value       = azurerm_redis_cache.redis.ssl_port # Use SSL port
      # }
      # env {
      #   name        = "REDIS_PASSWORD"
      #   secret_name = "redis-password"
      # }
      # env {
      #   name  = "REDIS_CHANNEL"
      #   value = "log_channel" # Or make this configurable
      # }
    }
    min_replicas = 1 # Run at least one instance
    max_replicas = 1 # Scale manually if needed based on queue length etc.
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }
  #  secret {
  #   name  = "redis-password"
  #   value = azurerm_redis_cache.redis.primary_access_key
  # }
}
