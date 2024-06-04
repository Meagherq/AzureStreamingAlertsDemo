resource "azurerm_stream_analytics_function_javascript_udf" "udf" {
  name                      = var.name
  stream_analytics_job_name = var.stream_analytics_job_name
  resource_group_name       = var.resource_group_name

  script = var.script

  dynamic "input" {
    for_each = var.inputs
    content {
      type = input.value
    } 
  }

  dynamic "output" {
    for_each = var.outputs
    content {
      type = output.value
    }
  }
}