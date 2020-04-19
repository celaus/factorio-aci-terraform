
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "fn-contributor-access" {
  scope              = azurerm_container_group.gameserv.id
  role_definition_id = "${azurerm_container_group.gameserv.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = azurerm_function_app.control.identity[0].principal_id
}

resource "azurerm_app_service_plan" "control-plan" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "control" {
  name                      = "${var.dns_label}-ctrl"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  app_service_plan_id       = azurerm_app_service_plan.control-plan.id
  storage_connection_string = azurerm_storage_account.data.primary_connection_string
  version                   = "~3"
  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~3"
    WEBSITE_RUN_FROM_PACKAGE    = var.package_deploy_url
    FUNCTIONS_WORKER_RUNTIME    = "dotnet"
    https_only                  = "true"
    FUNCTION_APP_EDIT_MODE      = "readonly"
    ACI_NAME                    = azurerm_container_group.gameserv.name
    ACI_RESOURCE_GROUP          = azurerm_resource_group.main.name
    AzureWebJobsDisableHomepage = "true"
  }
  identity {
    type = "SystemAssigned"
  }
}
