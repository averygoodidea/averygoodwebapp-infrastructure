terraform {
  backend "s3" {
    bucket = "averygoodwebapp-infrastructure-terraform"
    key    = "state"
    region = "us-east-1"
  }
}