
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.0.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.31.1"
    }
  }
}
provider "azurerm" {
  features {}
  version = "2.31.1"
}