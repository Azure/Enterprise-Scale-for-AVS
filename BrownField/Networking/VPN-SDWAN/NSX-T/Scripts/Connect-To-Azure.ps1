function Connect-To-Azure {
    param (
        [string]$tenantId,
        [string]$subscriptionId
    )
    Connect-AzAccount -TenantId $tenantId

    Set-AzContext -SubscriptionId $subscriptionId
}