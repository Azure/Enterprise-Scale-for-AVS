resource "azurerm_dashboard" "avs-dashboard" {
  name                = "AVSDashboard-${random_string.uniqueString.result}"
  resource_group_name = data.azurerm_resource_group.avs-dashboard.name
  location            = var.region
  tags = {
    hidden-title = var.dashboardName
  }
  dashboard_properties = templatefile("./resources/avs-dashboard.json", {
    privateCloudResourceId  = var.privateCloudResourceId,
    exRConnectionResourceId = var.exRConnectionResourceId
    }
  )
}