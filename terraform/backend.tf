terraform {
  backend "s3" {
    bucket = "koshermaple-com-infrastructure-terraform"
    key    = "state"
    region = "us-east-1"
  }
}