terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {
    # Add this block to allow deleting resource groups even if they contain resources
    # not managed by this Terraform configuration (like the commented-out Redis cache).
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  # Assumes Azure CLI login or other authentication method is configured
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
}
