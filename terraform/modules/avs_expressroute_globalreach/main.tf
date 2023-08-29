resource "azapi_resource" "globalreach_connections" {
  type = "Microsoft.AVS/privateClouds/globalReachConnections@2022-05-01"
  name = var.gr_connection_name
  parent_id = var.private_cloud_id
  body = jsonencode({
    properties = {
      authorizationKey = var.gr_remote_auth_key
      peerExpressRouteCircuit = var.gr_remote_expr_id
    }
  })
}