variable "firerecord_zone" {
  type    = string
  default = "averygoodweb.app"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "namespace" {
  type    = string
  default = "averygoodwebapp"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type    = string
  default = "test.averygoodweb.app"
}

# waterapi variables

variable "gatsby_webhook_id" {
  type = string
}

variable "sender_email_address" {
  type    = string
  default = "avery@averygoodidea.com"
}

# earthbucket variables

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "tinyletter_username" {
  type = string
}

variable "valine_leancloud_app_id" {
  type = string
}

variable "valine_leancloud_app_key" {
  type = string
}