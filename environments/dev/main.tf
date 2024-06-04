terraform {
  required_version = "=1.7.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "alerting_infra" {
    source = "../../levels/applications"

    environment = var.environment
    service_bus_topic_name = "monitor-alert-topic"
    service_bus_namespace_name = "monitor-alert-sg-ns"
    service_bus_resource_group_name = "monitor-alert-rg"

    log_analytics_workspace_name = "alert-law-${var.environment}"
    log_analytics_workspace_resource_group_name = "alert-law-rg-${var.environment}"

    private_dns_zone_resource_group_name = "private-dns-rg-${var.environment}"

    private_endpoint_subnet_name = "private-endpoints"
    private_endpoint_virtual_network_name = "apps-vnet-${var.environment}"
    private_endpoint_virtual_network_resource_group_name = "apps-vnet-rg-${var.environment}"
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  resource_id = "/subscriptions/d73c06de-7a04-4b79-b1ac-37e8b1b3cee4/resourceGroups/rg-stream-alerting-dev/providers/Microsoft.EventHub/namespaces/eh-ns-stream-alerting-dev"
}
