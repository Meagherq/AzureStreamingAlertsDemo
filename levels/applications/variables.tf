variable log_analytics_workspace_name {}
variable log_analytics_workspace_resource_group_name {}
variable private_dns_zone_resource_group_name {}
variable service_bus_namespace_name {}
variable service_bus_resource_group_name {}
variable service_bus_topic_name {}
variable location {
    default = "South Central US"
}
variable eventhub_sku {
    default = "Standard"
}
variable eventhub_capacity {
    default = 1
}
variable eventhub_partition_count {
    default = 2
}
variable workload_name {
    default = "stream-alerting"
}
variable environment {}
variable stream_analytics_streaming_units {
    default = 1
}
variable private_endpoint_subnet_name {}
variable private_endpoint_virtual_network_name {}
variable private_endpoint_virtual_network_resource_group_name {}