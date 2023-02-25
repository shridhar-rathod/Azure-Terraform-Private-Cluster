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
  subscription_id = "e467a365-7974-44d1-9662-420e45da1364"
  client_id = "35494f29-e6f3-42a4-a44a-47836e370c69"
  client_secret = "tvJ8Q~EGy3oCLXbkJOPZwBwQoU3N5Nn2TcOllao2"
  tenant_id = "07d232d9-966f-428e-a619-44029f667380"
  features {}
}