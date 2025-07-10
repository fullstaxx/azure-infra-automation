terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-rg"
    storage_account_name  = "tfbackend1234"
    container_name        = "tfstate"
    key                   = "phase1.terraform.tfstate"
  }
}
