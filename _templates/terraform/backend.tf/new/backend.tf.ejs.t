---
to: ./terraform/backend.tf
---
terraform {
  backend "s3" {
    bucket = "<%= terraformBackendBucket %>"
    key    = "state"
    region = "<%= region %>"
  }
}