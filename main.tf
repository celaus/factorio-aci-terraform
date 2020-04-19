variable REGION {
  default = "westeurope"
}

variable n_cores {
  default = 2
}

variable mem_gb {
  default = 4
}

variable package_deploy_url {
  default = "https://github.com/celaus/fn-manage-aci/releases/download/tag-7287778cb03583625477550ab8eb6fcabe5a7120/aci-manage.zip"
}

variable RESOURCE_GROUP_NAME {
  default = "factorio"
}

variable factorio_server_version {
  default = "0.18.15"
}

variable dns_label {}
variable tenantid {}
variable subid {}

provider "azurerm" {
  version = "~>2.2.0"
  features {}

  subscription_id = var.subid
  tenant_id       = var.tenantid
}

resource "azurerm_resource_group" "main" {
  name     = var.RESOURCE_GROUP_NAME
  location = var.REGION
}

resource "azurerm_storage_account" "data" {
  name                     = "factoriodata"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



resource "azurerm_storage_share" "gamedata" {
  name                 = "gamedata"
  storage_account_name = azurerm_storage_account.data.name
  quota                = 50
}


resource "azurerm_container_group" "gameserv" {
  name                = "factorio-gameserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "public"
  dns_name_label      = var.dns_label
  os_type             = "Linux"

  container {
    name   = "factoriogame"
    image  = "factoriotools/factorio:${var.factorio_server_version}"
    cpu    = var.n_cores
    memory = var.mem_gb

    ports {
      port     = 34197
      protocol = "UDP"
    }
    ports {
      port     = 27015
      protocol = "TCP"
    }

    volume {
      name                 = "gamedatamount"
      mount_path           = "/factorio"
      storage_account_name = azurerm_storage_account.data.name
      storage_account_key  = azurerm_storage_account.data.primary_access_key
      share_name           = azurerm_storage_share.gamedata.name
    }
  }
}
