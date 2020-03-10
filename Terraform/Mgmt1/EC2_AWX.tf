variable "VaultFile" {}

resource "aws_eip" "awx" {
  vpc = true
}

resource "aws_eip_association" "awx" {
  network_interface_id = aws_network_interface.awx.id
  allocation_id        = aws_eip.awx.id
}

resource "aws_network_interface" "awx" {
  depends_on = [aws_eip.awx]
  subnet_id       = aws_subnet.Public.id
  security_groups = [
    aws_security_group.ServiceSG.id,
    aws_security_group.CommonManagementSG.id
  ]
}

resource "aws_instance" "awx" {
  depends_on = [aws_network_interface.awx]
  tags = {
    Name = "awx"
    FQDN = "awx.${aws_eip.awx.public_ip}.${var.dns_suffix}"
  }

  ami           = var.ami_ubuntu1804
  instance_type = "t2.medium"
  key_name      = aws_key_pair.service.key_name

  network_interface {
    network_interface_id = aws_network_interface.awx.id
    device_index         = 0
  }

  user_data = <<USERDATA
#! /bin/bash
hostnamectl set-hostname awx.${aws_eip.awx.public_ip}.${var.dns_suffix}
#######################################################################################
# Install ansible dependencies
#######################################################################################
apt-get update
apt-get install -y python3-pip python-pip
pip3 install ansible ansible-tower-cli
pip2 install docker docker-compose
#######################################################################################
# Prepare AWX install
#######################################################################################
git clone https://github.com/JonTheNiceGuy/Install_AWX_And_Configure_It /tmp/build_playbook
git clone https://gist.github.com/e890209d96f29e2019c70a2f9e06a862.git /tmp/playbook_config
cd /tmp/build_playbook
ln -s /tmp/playbook_config/EC2_AWX_secrets.yml secrets.yml
ln -s /tmp/playbook_config/EC2_AWX_config.json run.json
mkdir /root/awx_build
echo "#!/bin/bash" > /root/awx_build/creds
echo "export AWX_Hostname=$(hostname)" >> /root/awx_build/creds
echo "export AWX_Password=\"${var.admin_password}\"" >> /root/awx_build/creds
echo "echo \"${var.VaultFile}\" > /tmp/build_playbook/vaultfile" >> /root/awx_build/creds
echo "echo \"{
  'ansible_fqdn':'$(hostname)',
  'admin_password':'${var.admin_password}'
}\" > /tmp/build_playbook/extra.json" >> /root/awx_build/creds
echo '$*' >> /root/awx_build/creds
chmod +x /root/awx_build/creds
/root/awx_build/creds ansible-playbook prepare_awx_install.yml -e "@/tmp/build_playbook/extra.json"
#######################################################################################
# Run AWX Install
#######################################################################################
cd /opt/awx/installer
ansible-playbook -i inventory install.yml
#######################################################################################
# Perform post-config of AWX
#######################################################################################
cd /tmp/build_playbook
/root/awx_build/creds bash ./run.sh
rm vaultfile
rm extra.json
USERDATA

  # Based on https://stackoverflow.com/a/12748070
  # and notes from https://github.com/hashicorp/terraform/issues/4668
  # -w '%%' syntax from https://github.com/terraform-providers/terraform-provider-template/issues/50
  provisioner "local-exec" {
    command = "until [ $(curl -k -s -w '%%{http_code}' https://awx.${aws_eip.awx.public_ip}.${var.dns_suffix}/api/ -o /dev/null) -eq 200 ] ; do curl -k -s -w 'Response from awx.${aws_eip.awx.public_ip}.${var.dns_suffix} was %%{http_code}\n' https://awx.${aws_eip.awx.public_ip}.${var.dns_suffix}/api/ -o /dev/null ; sleep 5 ; done"
  }
}
