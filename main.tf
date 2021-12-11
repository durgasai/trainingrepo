terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "demoresourcegroup" {
 source = "./modules"
 resource_group_name_prefix = var.customerrgnameprefix
 resource_group_location = var.customerrglocation
}
