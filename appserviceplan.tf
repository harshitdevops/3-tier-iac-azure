resource "azurerm_service_plan" "frontend-asp" {
  name                = "frontend-asp-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Premium app service plan sku supports Availability Zones and distrubuted scaling
  ///zone_balancing_enabled = true  # Enable zone redundancy | This will return an error on free account

  depends_on = [
    azurerm_subnet.frontend-subnet
  ]
}

resource "azurerm_service_plan" "backend-asp" {
  name                = "backend-asp-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Premium app service plan sku supports Availability Zones and distrubuted scaling
  ///zone_balancing_enabled = true  # Enable zone redundancy | This will return an error on free account

  depends_on = [
    azurerm_subnet.backend-subnet
  ]
}