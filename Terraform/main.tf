terraform {
  required_version = "~> 0.12"
}

data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}

# Default Provider
provider "aws" {
  version = "~> 2.52.0"
  region = "us-east-1"
}

provider "http" {
  version = "~> 1.1"
}

provider "local" {
  version = "~> 1.4.0"
}

provider "azurerm" {
  version = "~> 2.0.0"
  features {}
}