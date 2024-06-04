variable name {}
variable resource_group_name {}
variable location {}
variable events_late_arrival_max_delay_in_seconds {
    default = 60
}
variable events_out_of_order_max_delay_in_seconds {
    default = 50
}
variable sku_name {
    default = "Standard"
}
variable streaming_units {
    default = 1
}
variable transformation_query {}
variable log_analytics_workspace_id {}