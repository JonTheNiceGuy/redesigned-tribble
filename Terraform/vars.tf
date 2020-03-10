data "local_file" "vault_file" {
  filename = "${path.module}/vaultfile"
}

data "local_file" "key_file" {
  filename = "${path.module}/id_rsa.pub"
}

data "local_file" "admin_password" {
  filename = "${path.module}/admin_password"
}

# Note that if you're being blocked for LetsEncrypt Certs, you can always deploy your own instance
# of sslip.io by going to that page, and adding the NS records mentioned to a DNS record of your
# own, and then either amending this file, or creating an override.tf with a block like this one.
variable "dns_suffix" {
  default = "sslip.io"
}