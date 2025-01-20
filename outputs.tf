output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "frontend_url" {
  value = "${azurerm_linux_web_app.frontend-webapp.name}.azurewebsites.net"
}

output "backend_url" {
  value = "${azurerm_linux_function_app.backend-fnapp.name}.azurewebsites.net"
}