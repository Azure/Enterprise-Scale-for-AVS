$tenant_id = ""
$subscription_id = ""

#Connect-AzAccount
Login-AzAccount
$tenant = Get-AzTenant -TenantId $tenant_id
Set-AzContext -Tenant $tenant.Id
Select-AzSubscription -Subscription $subscription_id
