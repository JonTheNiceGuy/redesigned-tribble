module "Azure" {
  source                    = "./Azure"
  modulename                = "cust2"
  public_first_three_octets = "198.18.5"
  myip                      = "${trimspace(data.http.icanhazip.body)}/32"
  key                       = data.local_file.key_file.content
  awx_public_ip             = module.Mgmt_AWX.awxip
  vm_user                   = "fgtadmin"
  vm_password               = trimspace(data.local_file.admin_password.content)
  
  Region                    = "Central US"
}

output "Azure_IPs" {
  value = <<EOF
${module.Azure.ips}
EOF
}