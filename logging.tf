resource "azurerm_log_analytics_workspace" "ok-loganalytics" {
  name                = "ok-la-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "ok-appinsights" {
  name                = "ok-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.ok-loganalytics.id
  application_type    = "web"
  depends_on = [
    azurerm_log_analytics_workspace.ok-loganalytics
  ]
}