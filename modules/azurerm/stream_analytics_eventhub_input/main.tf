resource "azurerm_stream_analytics_stream_input_eventhub_v2" "eh_input" {
  name                         = var.name
  stream_analytics_job_id      = var.stream_analytics_job_id
  eventhub_consumer_group_name = var.eventhub_consumer_group_name
  eventhub_name                = var.eventhub_name
  servicebus_namespace         = var.servicebus_namespace
  authentication_mode          = "Msi"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }

  depends_on = [ azurerm_role_assignment.eh_sa_job_assignment ]
}

resource "azurerm_role_assignment" "eh_sa_job_assignment" {
    scope                = var.eventhub_namespace_id
    role_definition_name = "Azure Event Hubs Data Receiver"
    principal_id         = var.stream_analytics_job_user_assigned_principal_id
}