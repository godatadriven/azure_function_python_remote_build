# Configure the providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Configure the resources
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.prefix}${var.project}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "storage_account" {
  name                      = "${var.prefix}${var.project}storage"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.resource_group.name
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.tags
}

resource "azurerm_app_service_plan" "function_asp" {
  name                = "${var.prefix}-${var.project}-function-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = "FunctionApp"
  reserved            = true
  tags                = var.tags

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "${var.prefix}-${var.project}-functions"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.function_asp.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  https_only                 = true
  os_type                    = "linux"
  version                    = "~4"
  tags                       = var.tags

  site_config {
    linux_fx_version = "Python|3.9"
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
    FUNCTIONS_WORKER_RUNTIME       = "python"
  }
}

# Generate deploy script
resource "local_file" "deploy_azure_function" {
  filename = "${path.module}/../scripts/deploy_function_app.sh"
  content  = <<-CONTENT
    zip -r build/function_app.zip \
    app/ function/ host.json requirements.txt \
    -x '*__pycache__*' \

   az functionapp deployment source config-zip \
    --resource-group ${azurerm_resource_group.resource_group.name} \
    --name ${azurerm_function_app.function_app.name} \
    --src build/function_app.zip \
    --build-remote true \
    --verbose
  CONTENT
}