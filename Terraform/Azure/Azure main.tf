variable "modulename" {}
variable "public_first_three_octets" {}
variable "myip" {}
variable "key" {}
variable "awx_public_ip" {}
variable "vm_user" {}
variable "vm_password" {}

variable "Region" {}

resource "azurerm_resource_group" "ResourceGroup" {
  name     = "${var.modulename}ResourceGroup"
  location = var.Region
}

resource "azurerm_virtual_network" "VNet" {
  name                = "n${var.modulename}"
  address_space       = ["${var.public_first_three_octets}.0/24"]
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
}

resource "azurerm_subnet" "Public" {
  name                 = "s${var.modulename}public"
  resource_group_name  = azurerm_resource_group.ResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefix       = "${var.public_first_three_octets}.0/24"
}

output "ips" {
  value = <<EOF
fgt public: ${azurerm_public_ip.fgt.ip_address}
EOF
}