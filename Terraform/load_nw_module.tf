module "Mgmt_NW" {
  source                    = "./Mgmt_NW"
  modulename                = "CME"
  public_first_three_octets = "192.168.10"
  myip                      = "${trimspace(data.http.icanhazip.body)}/32"
  key                       = data.local_file.key_file.content
}