terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}
provider "azurerm" {
  features {}
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address  = "${azurerm_container_registry.this.name}.azurecr.io"
    username = azurerm_container_registry.this.admin_username
    password = azurerm_container_registry.this.admin_password
  }
}
