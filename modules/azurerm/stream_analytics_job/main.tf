resource "azurerm_stream_analytics_job" "job" {
  name                                     = var.name
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = var.events_late_arrival_max_delay_in_seconds
  events_out_of_order_max_delay_in_seconds = var.events_out_of_order_max_delay_in_seconds
  events_out_of_order_policy               = "Adjust"
  sku_name = var.sku_name
  streaming_units                          = var.streaming_units

  transformation_query = var.transformation_query

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }
}

resource "azurerm_user_assigned_identity" "identity" {
  location            = var.location
  name                = "${var.name}-uai"
  resource_group_name = var.resource_group_name
}

module "diagnostic_settings" {
  source = "../monitor_diagnostic_setting"

  resource_id = azurerm_stream_analytics_job.job.id
  name = "sa-job-diagnosticsetting"
  log_analytics_workspace_id = var.log_analytics_workspace_id
}