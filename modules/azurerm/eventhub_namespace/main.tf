resource "azurerm_eventhub_namespace" "ns" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
}

# module "diagnostic_settings" {
#   source = "../monitor_diagnostic_setting"

#   resource_id = azurerm_eventhub_namespace.ns.id
#   name = "eh-ns-diagnosticsetting"
#   log_analytics_workspace_id = var.log_analytics_workspace_id
# }

resource "azurerm_private_endpoint" "pe" {
  name                = "${azurerm_eventhub_namespace.ns.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_eventhub_namespace.ns.name}-pe-sc"
    subresource_names = [ "namespace" ]
    private_connection_resource_id = azurerm_eventhub_namespace.ns.id
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${azurerm_eventhub_namespace.ns.name}-dns-group"
    private_dns_zone_ids = [var.eventhub_private_dns_zone_id]
  }
}
