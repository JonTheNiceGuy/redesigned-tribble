module "Mgmt_Gitlab" {
  source          = "./Mgmt_Gitlab"
  modulename      = "CME"
  subnet          = module.Mgmt_NW.subnet
  security_groups = module.Mgmt_NW.security_groups
  dns_suffix      = var.dns_suffix
  ami_ubuntu1804  = data.aws_ami.ubuntu.id
  admin_password  = trimspace(data.local_file.admin_password.content)
  ssh_key         = module.Mgmt_NW.ssh_key
}

output "Mgmt_Gitlab" {
  value = <<OUTPUT
FQDN: ${module.Mgmt_Gitlab.gitlabfqdn} (use ${module.Mgmt_Gitlab.gitlabuser})
OUTPUT
}