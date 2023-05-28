resource "azurerm_resource_group" "this" {
  name     = "recruitment"
  location = var.location
}
resource "azurerm_service_plan" "this" {
  name                = "service_plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_container_registry" "this" {
  name                = "weatheraleksandra"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_linux_web_app" "backend" {
  name                = "weather-backend-aleksandra"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true

  app_settings = {
    APPID         = var.api_key
    WEBSITES_PORT = "9000"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [ docker_image.backend ]

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true

    application_stack {
      docker_image     = docker_image.backend.name
      docker_image_tag = "latest"
    }
  }
}

resource "azurerm_role_assignment" "backend" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.this.id
  principal_id         = azurerm_linux_web_app.backend.identity.0.principal_id
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "weather-frontend-aleksandra"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true

  app_settings = {
    ENDPOINT      = "https://${azurerm_linux_web_app.backend.default_hostname}/api"
    WEBSITES_PORT = "80"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [ docker_image.frontend ]

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true

    application_stack {
      docker_image     = docker_image.frontend.name
      docker_image_tag = "latest"
    }
  }
}

resource "azurerm_role_assignment" "frontend" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.this.id
  principal_id         = azurerm_linux_web_app.frontend.identity.0.principal_id
}
