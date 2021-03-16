---
to: ./terraform/variables.tf
---
variable "firerecord_zone" {
  type    = string
  default = "<%= firerecordZone %>"
}

variable "region" {
  type    = string
  default = "<%= region %>"
}

variable "namespace" {
  type    = string
  default = "<%= namespace %>"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type    = string
  default = "<%= domainName %>"
}

# waterapi variables

variable "gatsby_webhook_id" {
  type = string
}

variable "sender_email_address" {
  type    = string
  default = "<%= senderEmailAddress %>"
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