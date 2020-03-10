resource "aws_eip" "gitlab" {
  vpc = true
}

resource "aws_eip_association" "gitlab" {
  network_interface_id = aws_network_interface.gitlab.id
  allocation_id        = aws_eip.gitlab.id
}

resource "aws_network_interface" "gitlab" {
  depends_on = [aws_eip.gitlab]
  subnet_id       = aws_subnet.Public.id
  security_groups = [
    aws_security_group.ServiceSG.id,
    aws_security_group.CommonManagementSG.id
  ]
}

resource "aws_instance" "gitlab" {
  depends_on = [aws_network_interface.gitlab]
  tags = {
    Name = "gitlab"
    FQDN = "gitlab.${aws_eip.gitlab.public_ip}.${var.dns_suffix}"
  }

  ami           = var.ami_ubuntu1804
  instance_type = "t2.medium"
  key_name      = aws_key_pair.service.key_name

  network_interface {
    network_interface_id = aws_network_interface.gitlab.id
    device_index         = 0
  }

  user_data = <<USERDATA
#! /bin/bash
hostnamectl set-hostname gitlab.${aws_eip.gitlab.public_ip}.${var.dns_suffix}
#######################################################################################
# Install ansible dependencies
#######################################################################################
apt-get update
apt-get install -y python3-pip 
pip3 install ansible
git clone https://gist.github.com/14b5292a9ef6968c9fc92fd2df0c0ba3.git /tmp/gitlab-install
cd /tmp/gitlab-install
ansible-playbook install.yml -e '{"awx_password":"${var.admin_password}","admin_password":"${var.admin_password}","system_fqdn":"gitlab.${aws_eip.gitlab.public_ip}.${var.dns_suffix}"}'
USERDATA

  provisioner "local-exec" {
    command = "until [ $(curl -k -s -w '%%{http_code}' https://gitlab.${aws_eip.gitlab.public_ip}.${var.dns_suffix}/users/sign_in -o /dev/null) -eq 200 ] ; do curl -k -s -w 'Response from gitlab.${aws_eip.gitlab.public_ip}.${var.dns_suffix} was %%{http_code}\n' https://gitlab.${aws_eip.gitlab.public_ip}.${var.dns_suffix}/users/sign_in -o /dev/null ; sleep 5 ; done"
  }
}
