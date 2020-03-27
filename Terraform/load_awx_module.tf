variable "ConfigPath" {
  default = ""
}

module "Mgmt_AWX" {
  source          = "./Mgmt_AWX"
  modulename      = "CME"
  subnet          = module.Mgmt_NW.subnet
  security_groups = module.Mgmt_NW.security_groups
  dns_suffix      = var.dns_suffix
  ami_ubuntu1804  = data.aws_ami.ubuntu.id
  admin_password  = trimspace(data.local_file.admin_password.content)
  ssh_key         = module.Mgmt_NW.ssh_key
  VaultFile       = data.local_file.vault_file.content
  ConfigPath      = var.ConfigPath
}

output "Mgmt_AWX" {
  value = <<OUTPUT
FQDN: ${module.Mgmt_AWX.awxfqdn} (use ${module.Mgmt_AWX.awxuser})
OUTPUT
}