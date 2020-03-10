variable "modulename" {}
variable "public_first_three_octets" {}
variable "myip" {}
variable "key" {}
variable "awx_public_ip" {}
variable "vm_user" {}
variable "vm_password" {}

variable "ami_fortigate623" {}

resource "aws_key_pair" "service" {
  key_name = "${var.modulename} Service"
  public_key = var.key
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

output "ips" {
  value = <<EOF
fgt public: ${aws_eip.fgt.public_ip}
EOF
}