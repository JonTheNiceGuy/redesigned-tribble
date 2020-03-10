data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "fortigate6_2_3" {
  most_recent = true

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = "6\\.2\\.3"

  owners = ["679593333241"] # AWS Marketplace
}