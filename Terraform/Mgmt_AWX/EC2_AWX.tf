variable "modulename" {}
variable "subnet" {}
variable "security_groups" {}
variable "dns_suffix" {}
variable "ami_ubuntu1804" {}
variable "admin_password" {}
variable "ssh_key" {}
variable "VaultFile" {}
variable "ConfigPath" {
  default = ""
}
variable "CommonMgmtSGID" {}

resource "aws_eip" "awx" {
  vpc = true
}

resource "aws_eip_association" "awx" {
  network_interface_id = aws_network_interface.awx.id
  allocation_id        = aws_eip.awx.id
}

resource "aws_network_interface" "awx" {
  depends_on      = [aws_eip.awx]
  subnet_id       = var.subnet
  security_groups = var.security_groups
}

resource "aws_instance" "awx" {
  depends_on = [aws_network_interface.awx]
  tags = {
    Name = "awx"
    FQDN = "awx.${aws_eip.awx.public_ip}.${var.dns_suffix}"
  }

  ami           = var.ami_ubuntu1804
  instance_type = "t2.medium"
  key_name      = var.ssh_key

  network_interface {
    network_interface_id = aws_network_interface.awx.id
    device_index         = 0
  }

  user_data = templatefile("${path.module}/Custom Data - AWX.txt", {admin_password = var.admin_password, vaultfile = var.VaultFile, public_ip = aws_eip.awx.public_ip, dns_suffix = var.dns_suffix, ConfigPath = var.ConfigPath})

  # Based on https://stackoverflow.com/a/12748070
  # and notes from https://github.com/hashicorp/terraform/issues/4668
  # -w '%%' syntax from https://github.com/terraform-providers/terraform-provider-template/issues/50
  provisioner "local-exec" {
    command = "until [ $(curl -k -s -w '%%{http_code}' https://awx.${aws_eip.awx.public_ip}.${var.dns_suffix}/api/ -o /dev/null) -eq 200 ] ; do curl -k -s -w 'Response from awx.${aws_eip.awx.public_ip}.${var.dns_suffix} was %%{http_code}\n' https://awx.${aws_eip.awx.public_ip}.${var.dns_suffix}/api/ -o /dev/null ; sleep 5 ; done"
  }
}

output "awxip" {
  value = aws_eip.awx.public_ip
}

output "awxfqdn" {
  value = "awx.${aws_eip.awx.public_ip}.${var.dns_suffix}"
}

output "awxuser" {
  value = "admin"
}

# Hack to get around the fact we don't know the public IP address of the AWX until this module is done

resource "aws_security_group_rule" "CommonManagementSG_SSH_From_AWX" {
  type = "ingress"  
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["${aws_eip.awx.public_ip}/32"]
  security_group_id = var.CommonMgmtSGID
}