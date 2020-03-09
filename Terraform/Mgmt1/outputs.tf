output "fqdn" {
  value = <<EOF
awx.${aws_eip.awx.public_ip}.nip.io
gitlab.${aws_eip.gitlab.public_ip}.nip.io
EOF
}

output "awxip" {
  value = aws_eip.awx.public_ip
}

output "admin_password" {
  value = var.admin_password
}

output "ips" {
  value = <<EOF
awx: ${aws_eip.awx.public_ip}
awx private: ${aws_instance.awx.private_ip}
gitlab: ${aws_eip.gitlab.public_ip}
gitlab private: ${aws_instance.gitlab.private_ip}
EOF
}
