variable "modulename" {}
variable "public_first_three_octets" {}
variable "myip" {}
variable "key" {}

resource "aws_key_pair" "service" {
  key_name = var.modulename
  public_key = var.key
}

output "ssh_key" {
  value = aws_key_pair.service.key_name
}

resource "aws_vpc" "VPC" {
  cidr_block  = "${var.public_first_three_octets}.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "n${var.modulename}"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "g${var.modulename}"
  }
}

resource "aws_subnet" "Public" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "${var.public_first_three_octets}.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "s${var.modulename}_public"
  }
}

output "subnet" {
  value = aws_subnet.Public.id
}

resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "r${var.modulename}_public"
  }
}

resource "aws_route" "PublicDefault" {
  route_table_id = aws_route_table.Public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.InternetGateway.id
}

resource "aws_route_table_association" "PublicAssociation" {
  subnet_id = aws_subnet.Public.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_security_group" "ServiceSG" {
  name = "ServiceSG"
  description = "Service security group"
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "ServiceSG"
  }
}

resource "aws_security_group" "CommonManagementSG" {
  name = "CommonManagementSG"
  description = "Common Management security group"
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "CommonManagementSG"
  }
}

output "security_groups" {
  value = [
    aws_security_group.ServiceSG.id, aws_security_group.CommonManagementSG.id
  ]
}

output "CommonManagementSG_ID" {
  value = aws_security_group.CommonManagementSG.id
}

resource "aws_security_group_rule" "ServicesSG_HTTP" {
  type = "ingress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ServiceSG.id
}

resource "aws_security_group_rule" "ServicesSG_HTTPS" {
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ServiceSG.id
}

resource "aws_security_group_rule" "ServicesSG_Egress_All" {
  type = "egress"
  protocol = "-1"
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ServiceSG.id
}

resource "aws_security_group_rule" "CommonManagementSG_ICMP_From_MyIP" {
  type = "ingress"  
  protocol = "icmp"
  from_port = -1
  to_port = -1
  cidr_blocks = [var.myip]
  security_group_id = aws_security_group.CommonManagementSG.id
}

resource "aws_security_group_rule" "CommonManagementSG_SSH_From_MyIP" {
  type = "ingress"  
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = [var.myip]
  security_group_id = aws_security_group.CommonManagementSG.id
}