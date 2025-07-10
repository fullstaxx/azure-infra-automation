provider "azurerm" {
  features {}
  subscription_id = "11b07e3a-0c42-4f40-a523-c42703579542"
}

resource "azurerm_resource_group" "rg" {
  name     = "phase1-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "phase1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "phase1-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.1.1"     # replace with your real IP
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "phase1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "phase1-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

admin_ssh_key {
  username   = "azureuser"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDY4M5OvvWNMkbMexlm7kt7vYTEA9qAhaC0DdFnExzF8cX/eJCBquKAarfEGedp9lmadAxCr755NcHrqgdZitpvV4Q8TJ0lIgpiAVDvlrFYoLl+e4YCHLq9JkMfKytkKeEQFT7tQw4ePtdBkx4k2+11XVLa88C7b6iCmqqj+gjJte65PHaUwqBhyzZGBc7dmJqG0g42Peo8KTBmKwXW+MxMQSiBUp7Z0Ivuzui7SUF7xciJYrceskV3jgT07EvPh25cobYgI0653dTdfvzAFA4fRdLSq6Ql8EcyLesUnjDOECO7o+YP9hgD5WIH6GiFxAnX2JEoWNsXoK6KbqJTE9HdLS68Rho0j7KdBzY6jmyCxvF2686dZEgAM5wfOTPgwpvZlCNe2MDY6fj38qh/nq38iFJVlgeolIPDu2Fzt4+mXtu2i/70A+4UVfn4TsLTYa0Wf2ILRkbBoOuao1HPwW6kZLuNozn1rXAjr+CInkTmlo9Kc3EfL57lKXMXY68APlSMo3LQR1VV9VKVYYjLktmD2hFpGIA3vLstLpnvJ5PdcDnmSSFXSq/eU4vLdC1A6K9dAqYci0Z6/AEDTxw/BAnsEm3ysdl95m6ABq6ssCHP7+dGO51hpxnRLShkZT6ykn9DzvWVD7dzEZH8/0yJ7GmNT5S4XSCUiLiEsWCCmEoFEw== fullstaxx@MacBookPro"
}

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}