resource "azurerm_linux_virtual_machine" "fgt" {
  name                  = "${var.modulename}fgt"
  location              = azurerm_resource_group.ResourceGroup.location
  resource_group_name   = azurerm_resource_group.ResourceGroup.name
  network_interface_ids = [azurerm_network_interface.fgt.id]
  size                  = "Standard_B1s"
  admin_username        = var.vm_user
  admin_password        = var.vm_password
  computer_name         = "${var.modulename}fgt"
  custom_data           = base64encode(templatefile("${path.module}/Custom Data - Fortigate.txt", {vm_user = var.vm_user, key = var.key, vm_password = var.vm_password, hostname = "${var.modulename}fgt"}))
  disable_password_authentication = false

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm_payg_20190624"
    version   = "6.2.3"
  }

  plan {
    name      = "fortinet_fg-vm_payg_20190624"
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
  }

  os_disk {
    name                 = "disk${var.modulename}fgt"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 10
  }

  tags = {
    fortigate = "true"
    fortigate_db = "true"
  }
}

resource "azurerm_network_interface_security_group_association" "fgt" {
  network_interface_id      = azurerm_network_interface.fgt.id
  network_security_group_id = azurerm_network_security_group.fgt.id
}

resource "azurerm_network_interface" "fgt" {
  name                      = "nic${var.modulename}fgt"
  location                  = azurerm_resource_group.ResourceGroup.location
  resource_group_name       = azurerm_resource_group.ResourceGroup.name

  ip_configuration {
    name                          = "ip${var.modulename}fgt"
    subnet_id                     = azurerm_subnet.Public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fgt.id
  }
}

resource "azurerm_public_ip" "fgt" {
  name                = "pip${var.modulename}fgt"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "fgt" {
  name                = "nsg${var.modulename}fgt"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
}

resource "azurerm_network_security_rule" "awxSshIn" {
  name                        = "awxSshIn"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.awx_public_ip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ResourceGroup.name
  network_security_group_name = azurerm_network_security_group.fgt.name
}

resource "azurerm_network_security_rule" "mySshIn" {
  name                        = "mySshIn"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.myip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ResourceGroup.name
  network_security_group_name = azurerm_network_security_group.fgt.name
}

resource "azurerm_network_security_rule" "awxHttpsIn" {
  name                        = "awxHttpsIn"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "${var.awx_public_ip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ResourceGroup.name
  network_security_group_name = azurerm_network_security_group.fgt.name
}

resource "azurerm_network_security_rule" "myHttpsIn" {
  name                        = "myHttpsIn"
  priority                    = 201
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.myip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ResourceGroup.name
  network_security_group_name = azurerm_network_security_group.fgt.name
}
