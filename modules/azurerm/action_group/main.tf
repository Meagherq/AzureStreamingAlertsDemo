resource "azurerm_monitor_action_group" "example" {
  name                = var.name
  resource_group_name = var.resource_group_name
  short_name          = var.short_name

  dynamic "event_hub_receiver" {
    for_each = {for x in var.eventhub_receivers : x.receiver_name => x}

    content {
        name                    = event_hub_receiver.value["receiver_name"]
        event_hub_namespace     = event_hub_receiver.value["event_hub_namespace"]
        event_hub_name          = event_hub_receiver.value["event_hub_name"]
        subscription_id         = event_hub_receiver.value["subscription_id"]
        use_common_alert_schema = true
    }
  }
}