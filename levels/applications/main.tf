# Data References
data "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}

data "azurerm_private_dns_zone" "sb_zone" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_servicebus_namespace" "sb_namespace" {
  name                = var.service_bus_namespace_name
  resource_group_name = var.service_bus_resource_group_name
}

data "azurerm_servicebus_topic" "sb_topic" {
  name         = var.service_bus_topic_name
  namespace_id = data.azurerm_servicebus_namespace.sb_namespace.id
}

data "azurerm_subnet" "pe_subnet" {
  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_virtual_network_name
  resource_group_name  = var.private_endpoint_virtual_network_resource_group_name
}

data "azurerm_client_config" "current" {}

# Locals
locals {
  stream_analytics_eventhub_input_name     = "eh-input"
  stream_analytics_service_bus_output_name = "sb-output"
  stream_analytics_array_udf_name          = "EventTransormer"
}

# Resources
module "resource_group" {
  source   = "../../modules/azurerm/resource_group"
  name     = "rg-${var.workload_name}-${var.environment}"
  location = var.location
}

module "action_group" {
  source              = "../../modules/azurerm/action_group"
  name                = "ag-${var.workload_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  short_name          = "ag-alert-${var.environment}"

  eventhub_receivers = [
    {
      receiver_name       = "eh-receiver-${var.environment}"
      event_hub_namespace = module.eventhub_namespace.name
      event_hub_name      = module.eventhub.name
      subscription_id     = data.azurerm_client_config.current.subscription_id
    }
  ]
}

module "eventhub_namespace" {
  source = "../../modules/azurerm/eventhub_namespace"

  name                         = "eh-ns-${var.workload_name}-${var.environment}"
  location                     = module.resource_group.location
  resource_group_name          = module.resource_group.name
  sku                          = var.eventhub_sku
  capacity                     = var.eventhub_capacity
  log_analytics_workspace_id   = data.azurerm_log_analytics_workspace.law.id
  private_endpoint_subnet_id   = data.azurerm_subnet.pe_subnet.id
  eventhub_private_dns_zone_id = data.azurerm_private_dns_zone.sb_zone.id
}

module "eventhub" {
  source = "../../modules/azurerm/eventhub"

  name                    = "eh-${var.workload_name}-${var.environment}"
  eventhub_namespace_name = module.eventhub_namespace.name
  resource_group_name     = module.resource_group.name
  partition_count         = var.eventhub_partition_count
}

module "eventhub_consumer_group" {
  source = "../../modules/azurerm/eventhub_consumer_group"

  name                = "cg-${var.workload_name}-${var.environment}"
  eventhub_name       = module.eventhub.name
  namespace_name      = module.eventhub_namespace.name
  resource_group_name = module.resource_group.name
}

module "stream_analytics_job" {
  source = "../../modules/azurerm/stream_analytics_job"

  name                       = "sa-job-${var.workload_name}-${var.environment}"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  streaming_units            = var.stream_analytics_streaming_units
  transformation_query       = <<QUERY
    SELECT 
        NULL as data,
        udf.${local.stream_analytics_array_udf_name}(data) as event
    INTO [${local.stream_analytics_service_bus_output_name}]
    FROM [${local.stream_analytics_eventhub_input_name}]
QUERY
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
}

module "stream_analytics_eventhub_input" {
  source = "../../modules/azurerm/stream_analytics_eventhub_input"

  name                                            = local.stream_analytics_eventhub_input_name
  stream_analytics_job_id                         = module.stream_analytics_job.id
  eventhub_consumer_group_name                    = module.eventhub_consumer_group.name
  eventhub_name                                   = module.eventhub.name
  servicebus_namespace                            = module.eventhub_namespace.name
  eventhub_namespace_id                           = module.eventhub_namespace.id
  stream_analytics_job_user_assigned_principal_id = module.stream_analytics_job.user_assigned_principal_id
}

module "stream_analytics_service_bus_output" {
  source = "../../modules/azurerm/stream_analytics_service_bus_output"

  name                      = local.stream_analytics_service_bus_output_name
  stream_analytics_job_name = module.stream_analytics_job.name
  servicebus_namespace      = data.azurerm_servicebus_namespace.sb_namespace.name
  servicebus_namespace_id   = data.azurerm_servicebus_namespace.sb_namespace.id
  topic_name                = data.azurerm_servicebus_topic.sb_topic.name
  resource_group_name       = module.resource_group.name
  stream_analytics_job_user_assigned_principal_id = module.stream_analytics_job.user_assigned_principal_id
  authentication_mode = "Msi"
}

module "stream_analytics_array_udf" {
  source = "../../modules/azurerm/stream_analytics_udf_javascript"

  name                      = local.stream_analytics_array_udf_name
  stream_analytics_job_name = module.stream_analytics_job.name
  resource_group_name       = module.resource_group.name

  script  = <<SCRIPT
function main(arg) {
  try {
    const result = {
      "notification": {
        "recipientType": "Employee",
        "content": "test message",
        "sendFromSystem": "Postman",
        "subject": "Test from postman",
        "recipients": [
          {
            "recipientId": arg.customProperties.recipientId,
            "defaults": [
              {
                "channel": arg.customProperties.channel,
                "address": arg.customProperties.address
              }
            ],
            "joint": false
          }
        ]
      }
    }
    return result
  } catch (ex) {
    console.warn(ex + ":" + JSON.stringify(arg));
    return arg
  }
}
SCRIPT
  inputs  = ["any"]
  outputs = ["any"]

}
