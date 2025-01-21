# Random password for complexity 
resource "random_password" "randompassword" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


#Azure sql database
resource "azurerm_mssql_server" "azuresql" {
  name                         = "ok-sqldb-prod"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0" #Expected versions are "2.0" or "12.0"
  administrator_login          = "UserAdm!n24"
  administrator_login_password = random_password.randompassword.result

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = "87c6f7a9-f76b-4725-8277-5edc82e0c4dc"
  }
}

#add subnet from the backend vnet
resource "azurerm_mssql_virtual_network_rule" "allow-be" {
  name      = "be-sql-vnet-rule"
  server_id = azurerm_mssql_server.azuresql.id
  subnet_id = azurerm_subnet.backend-subnet.id
  depends_on = [
    azurerm_mssql_server.azuresql
  ]
}

resource "azurerm_mssql_database" "ok-database" {
  name           = "ok-db"
  server_id      = azurerm_mssql_server.azuresql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false

  tags = {
    Application = "task1"
    Env         = "Prod"
  }
}

#Create Key Vault Secret
resource "azurerm_key_vault_secret" "sqladminpassword" {
  # checkov:skip=CKV_AZURE_41:Expiration not needed 
  name         = "sqladmin"
  value        = random_password.randompassword.result
  key_vault_id = azurerm_key_vault.ok-keyvault.id
  content_type = "text/plain"
  depends_on = [
    azurerm_key_vault.ok-keyvault,
    azurerm_key_vault_access_policy.kv_access_policy_sc,
    azurerm_key_vault_access_policy.kv_access_policy_me,
    azurerm_key_vault_access_policy.kv_access_policy_web_app
  ]
}

resource "azurerm_key_vault_secret" "sqldb_cnxn" {
  name         = "sqldbconstring"
  value        = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:ok-sqldb-prod.database.windows.net,1433;Database=ok-db;Uid=UserAdm!n24;Pwd=${random_password.randompassword.result};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.ok-keyvault.id
  depends_on = [
    azurerm_key_vault.ok-keyvault,
    azurerm_key_vault_access_policy.kv_access_policy_sc,
    azurerm_key_vault_access_policy.kv_access_policy_me,
    azurerm_key_vault_access_policy.kv_access_policy_web_app
  ]
}