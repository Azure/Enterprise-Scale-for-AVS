function Get-Tokens {
    param (
        [string]$TenantID,
        [string]$SubscriptionID,
        [switch]$ForceRefresh
    )

    try {
        Write-Host "Retrieving Azure tokens for Tenant: $TenantID, Subscription: $SubscriptionID"
        # Check if we already have a valid token (unless ForceRefresh is specified)
        if (-not $ForceRefresh) {
            try {
                $existingToken = Get-AzAccessToken -ResourceUrl "https://management.azure.com/" -AsSecureString -ErrorAction Stop
                if ($existingToken -and $existingToken.ExpiresOn -gt (Get-Date).AddMinutes(5)) {
                    #Write-Host "Using existing valid token (expires: $($existingToken.ExpiresOn))"
                    return @{
                        token = $existingToken
                        secureToken = $existingToken.Token
                    }
                }
                else {
                    #Write-Host "Existing token is expired or expires within 5 minutes, requesting new token..."
                }
            }
            catch {
                Write-Host "No existing token found, requesting new token..."
            }
        }
        else {
            Write-Host "Force refresh requested, getting new token..."
        }

        # Check if we're already connected to Azure with the right tenant/subscription
        $currentContext = Get-AzContext -ErrorAction SilentlyContinue
        if ($currentContext -and 
            $currentContext.Tenant.Id -eq $TenantID -and 
            $currentContext.Subscription.Id -eq $SubscriptionID) {
            Write-Host "Already connected to correct tenant and subscription"
        }
        else {
            # Connect to Azure account and set the context to a specific subscription
            Write-Host "Connecting to Azure (Tenant: $TenantID, Subscription: $SubscriptionID)..."
            Connect-AzAccount -TenantId $TenantID -ErrorAction Stop
            Set-AzContext -Tenant $TenantID -SubscriptionId $SubscriptionID -ErrorAction Stop
        }

        # Get the Azure session token
        $token = Get-AzAccessToken -ResourceUrl "https://management.azure.com/" -ErrorAction Stop
        Write-Host "New token acquired (expires: $($token.ExpiresOn))"

        # Return the tokens
        return @{
            token = $token
            secureToken = ConvertTo-SecureString $token.Token -AsPlainText -Force
        }

    }
    catch {
        Write-Error "Get Tokens failed: $_"
    }
}