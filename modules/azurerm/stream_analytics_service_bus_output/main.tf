resource "azurerm_stream_analytics_output_servicebus_topic" "sb_ouput" {
  name                      = var.name
  stream_analytics_job_name = var.stream_analytics_job_name
  resource_group_name       = var.resource_group_name
  topic_name                = var.topic_name
  servicebus_namespace      = var.servicebus_namespace
  authentication_mode       = var.authentication_mode

  serialization {
    type   = "Json"
    format = "LineSeparated"
    encoding = "UTF8"
  }

  depends_on = [ azurerm_role_assignment.sb_sa_job_assignment ]
}

resource "azurerm_role_assignment" "sb_sa_job_assignment" {
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.stream_analytics_job_user_assigned_principal_id
}
