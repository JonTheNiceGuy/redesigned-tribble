terraform {
  required_version = ">= 0.12"
}

data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}

# Default Provider
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {}