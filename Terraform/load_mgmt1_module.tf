module "Mgmt1" {
  source                    = "./Mgmt1"
  modulename                = "Mgmt1"
  public_first_three_octets = "192.168.10"
  ami_ubuntu1804            = data.aws_ami.ubuntu.id
  myip                      = "${trimspace(data.http.icanhazip.body)}/32"
  admin_password            = trimspace(data.local_file.admin_password.content)
  key                       = data.local_file.key_file.content
  VaultFile                 = data.local_file.vault_file.content
  dns_suffix                = var.dns_suffix
}

output "Mgmt1_IPs" {
  value = <<EOF
${module.Mgmt1.ips}
EOF
}