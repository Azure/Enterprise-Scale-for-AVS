output "logging_object_id" {
  value = azuread_service_principal.log_procesing_principal.object_id
}

output "logging_application_id" {
  value = azuread_application.log_processing_principal.application_id
}

output "logging_application_secret" {
  value = azuread_application_password.log_processing_principal.value
}