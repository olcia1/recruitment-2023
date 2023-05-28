resource "docker_registry_image" "frontend" {
  name          = docker_image.frontend.name
  keep_remotely = true
}

resource "docker_image" "frontend" {
  name = "${azurerm_container_registry.this.name}.azurecr.io/frontend"
  build {
    context    = "${path.cwd}/frontend"
    dockerfile = "Dockerfile.prod"
    tag        = ["frontend:latest"]
    build_args = {
      ENDPOINT : "https://${azurerm_linux_web_app.backend.default_hostname}/api"
    }
  }
}

resource "docker_registry_image" "backend" {
  name          = docker_image.backend.name
  keep_remotely = true
}

resource "docker_image" "backend" {
  name = "${azurerm_container_registry.this.name}.azurecr.io/backend"
  build {
    context = "${path.cwd}/backend"
    tag     = ["backend:latest"]
  }
}
