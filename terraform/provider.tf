terraform {
  required_version = " >=0.12"
}

#Default Provider
provider "aws" {
  region  = var.region
#   profile = var.profile

  version = "~> 3.14.1"
}