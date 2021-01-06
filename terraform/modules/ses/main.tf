resource "aws_ses_configuration_set" "api" {
  name = "${var.namespace}-${var.environment}-WaterApiSESConfigSet"
}

resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "${var.namespace}-${var.environment}-WaterApiSESCWEventDestination"
  configuration_set_name = aws_ses_configuration_set.api.name
  enabled                = true
  matching_types         = ["bounce", "complaint", "delivery", "reject", "send"]

  cloudwatch_destination {
    default_value  = "null"
    dimension_name = aws_ses_configuration_set.api.name
    value_source   = "emailHeader"
  }
}