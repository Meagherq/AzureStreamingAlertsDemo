variable name {}
variable stream_analytics_job_name {}
variable resource_group_name {}
variable topic_name {}
variable servicebus_namespace {}
variable servicebus_namespace_id {}
variable stream_analytics_job_user_assigned_principal_id {
    default = null
}
variable authentication_mode {
    default = "Msi"
}
variable shared_access_policy_name {
    default = null
}
variable shared_access_policy_key {
    default = null
}