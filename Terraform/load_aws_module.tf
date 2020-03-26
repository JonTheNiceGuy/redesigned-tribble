module "AWS" {
  source                    = "./AWS"
  modulename                = "cust1"
  public_first_three_octets = "198.18.3"
  myip                      = "${trimspace(data.http.icanhazip.body)}/32"
  key                       = data.local_file.key_file.content
  awx_public_ip             = module.Mgmt_AWX.awxip
  vm_user                   = "fgtadmin"
  vm_password               = trimspace(data.local_file.admin_password.content)

  ami_fortigate623          = data.aws_ami.fortigate6_2_3.id
}

output "AWS_IPs" {
  value = <<EOF
${module.AWS.ips}
EOF
}