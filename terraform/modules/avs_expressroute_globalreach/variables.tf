variable "gr_connection_name" {
  type = string
  description = "Name for the new global reach connection"
}

variable "private_cloud_id" {
  type = string
  description = "The Azure Resource ID for the private cloud where the global reach connection will originate from"
}

variable "gr_remote_auth_key" {
  type = string
  description = "The authorization key value for the remote expressRoute where the global reach connection will connect to"
}

variable "gr_remote_expr_id" {
  type = string
  description = "The Azure Resource ID for the remote expressRoute circuit where the global reach connection will connect to"
}