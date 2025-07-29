function Get-Tokens {
    param (
        [string]$TenantID,
        [string]$SubscriptionID
    )

    try {
        # Connect to Azure account and set the context to a specific subscription
        Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId -ErrorAction Stop
        Set-AzContext -Tenant $tenantId -SubscriptionId $subscriptionId -ErrorAction Stop

        # Get the Azure session token
        $token = Get-AzAccessToken -ResourceUrl "https://management.azure.com/" -AsSecureString -ErrorAction Stop
        $graphToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/" -AsSecureString -ErrorAction Stop
        $secureToken = $token.Token
        $secureGraphToken = $graphToken.Token

        # Return the tokens
        return @{
            token = $token
            secureToken = $secureToken
            secureGraphToken = $secureGraphToken
        }

    }
    catch {
        Write-Error "Get Tokens failed: $_"
    }
}