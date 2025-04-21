variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "East US" # Changed default region
}

variable "resource_prefix" {
  description = "A prefix to apply to all resource names."
  type        = string
  default     = "ingesoft5"
}

variable "acr_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
  default     = "Standard"
}

# variable "redis_sku_name" {
#   description = "The SKU name for the Azure Cache for Redis."
#   type        = string
#   default     = "Basic"
# }
# 
# variable "redis_family" {
#   description = "The SKU family for the Azure Cache for Redis."
#   type        = string
#   default     = "C"
# }
# 
# variable "redis_capacity" {
#   description = "The SKU capacity for the Azure Cache for Redis."
#   type        = number
#   default     = 0 # Corresponds to C0
# }
