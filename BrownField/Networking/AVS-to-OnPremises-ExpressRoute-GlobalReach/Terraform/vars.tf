variable "expressRouteAuthorizationKey" {
  type        = string
  sensitive   = true
  description = "The Express Route Authorization Key to be redeemed by the connection"
}

variable "expressRouteId" {
  type        = string
  sensitive   = true
  description = "The Express Route ID to create the connection to"
}

variable "PrivateCloudName" {
  type        = string
  description = "The name of the existing Private Cloud that should be used for the connection"
}