output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.identity.id
}

output "user_assigned_principal_id" {
  value = azurerm_user_assigned_identity.identity.principal_id
}

output "id" {
  value = azurerm_stream_analytics_job.job.id
}

output "name" {
    value = azurerm_stream_analytics_job.job.name
}