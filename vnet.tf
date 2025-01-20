# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "task1-vnet-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


#Create subnets
resource "azurerm_subnet" "frontend-subnet" {
  name                 = "frontend-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/26"]
  service_endpoints    = ["Microsoft.Web"] # if it's not passed then it gives microsoft web service endpoint not found on subnet

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }


  }

  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}

# Creating subnets
resource "azurerm_subnet" "backend-subnet" {
  name                 = "backend-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.64/26"]
  service_endpoints    = ["Microsoft.Sql"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }


  }

  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}
