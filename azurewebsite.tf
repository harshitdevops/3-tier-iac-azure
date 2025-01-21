#Frontend
# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "frontend-webapp" {
  name                = "frontend-webapp-har-2025"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.frontend-asp.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    always_on           = true # Must only be false when using free or shared service plans

    application_stack {
      node_version = "20-lts" # Version 20 long term support
    }

    ip_restriction {
      action     = "Allow"
      ip_address = "0.0.0.0/0" # Allows all IPs
      name       = "allow-all-demo"
      priority   = 100
    }
  }

  #App Settings for Application insight
  app_settings = { #A map of key-value pairs of App Settings

    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.ok-appinsights.instrumentation_key # Connecting the app to Application insights
    "APPINSIGHTS_PROFILERFEATURE_VERSION"        = "1.0.0"                                                         # Profiler to identify code that slowed down web app
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"                                                            # Insight agent that collects telemetry, version 3
  }

  #Allows the web app to use other azure services without needing to manage credentials (long version for github, short for actual code)
  identity {
    type = "SystemAssigned" #The identity is only valid for the lifespan of the resource
  }


  depends_on = [
    azurerm_service_plan.frontend-asp, azurerm_application_insights.ok-appinsights
  ]
}

#Backend
#storage account for functionapp
resource "azurerm_storage_account" "fn-storageaccount" {
  name                     = "functionapp2025sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_function_app" "backend-fnapp" {
  name                = "backend-functionapp-har-2025"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.fn-storageaccount.name
  storage_account_access_key = azurerm_storage_account.fn-storageaccount.primary_access_key
  service_plan_id            = azurerm_service_plan.backend-asp.id

  #App Settings for Application insight
  app_settings = { #A map of key-value pairs of App Settings   

    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.ok-appinsights.instrumentation_key # Connecting the app to Application insights
    "APPINSIGHTS_PROFILERFEATURE_VERSION"        = "1.0.0"                                                         # Profiler to identify code that slowed down web app
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"                                                            # Insight agent that collects telemetry, version 3


  }

  site_config {
    # only allows communication from that subnet
    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.frontend-subnet.id
      priority                  = 100
      name                      = "Frontend access only"
    }
    application_stack {
      python_version = 3.12 # Latest version at the time of creation
    }
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_storage_account.fn-storageaccount
  ]
}

#vnet integration of backend functions
resource "azurerm_app_service_virtual_network_swift_connection" "be-vnet-integration" {
  app_service_id = azurerm_linux_function_app.backend-fnapp.id
  subnet_id      = azurerm_subnet.backend-subnet.id
  depends_on = [
    azurerm_linux_function_app.backend-fnapp,
    azurerm_subnet.backend-subnet
  ]
}

#vnet integration of frontend functions
resource "azurerm_app_service_virtual_network_swift_connection" "frontend-vnet-integration" {
  app_service_id = azurerm_linux_web_app.frontend-webapp.id
  subnet_id      = azurerm_subnet.frontend-subnet.id

  depends_on = [
    azurerm_linux_web_app.frontend-webapp,
    azurerm_subnet.frontend-subnet
  ]
}
