terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "3c8ef418-5379-4fcb-84d7-a7610e299d97"
  client_id = "878ce04e-4071-47a1-8e16-3244dcb60f59"
  client_secret = "WYG8Q~tS~uhm8nz_b6XuJ-Wm8Ejldm78vCiywcZu"
  tenant_id = "77428205-87ff-4048-a645-91b337240228"
  features {}
}