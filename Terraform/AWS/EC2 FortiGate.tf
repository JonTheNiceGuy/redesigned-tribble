resource "aws_eip" "fgt" {
  vpc = true
}

resource "aws_eip_association" "fgt" {
  network_interface_id = aws_network_interface.fgt.id
  allocation_id        = aws_eip.fgt.id
}

resource "aws_network_interface" "fgt" {
  depends_on = [aws_eip.fgt]
  subnet_id       = aws_subnet.Public.id
  security_groups = [
    aws_security_group.fgtSG.id
  ]
}

resource "aws_instance" "fgt" {
  depends_on = [aws_network_interface.fgt]
  tags = {
    Name = "${var.modulename}fgt"
    fortigate = "true"
    fortigate_web = "true"
    fortigate_admin = "true"
  }

  ami           = var.ami_fortigate623
  instance_type = "t2.small"
  key_name      = aws_key_pair.service.key_name

  network_interface {
    network_interface_id = aws_network_interface.fgt.id
    device_index         = 0
  }

  user_data = templatefile("${path.module}/Custom Data - Fortigate.txt", {vm_user = var.vm_user, key = var.key, vm_password = var.vm_password, hostname = "${var.modulename}fgt"})
}

resource "aws_security_group" "fgtSG" {
  name = "fgtSG"
  description = "fgt security group"
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "fgtSG"
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["${var.awx_public_ip}/32", var.myip]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["${var.awx_public_ip}/32", var.myip]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["${var.awx_public_ip}/32", var.myip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
