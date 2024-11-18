. .\Get-AVS-SDDC-Details.ps1
function Test-TenantElibility-For-PIM {
    param (
        [string]$tenant
    )
    try{
        $token = (Get-AzAccessToken -TenantId $tenant -ResourceUrl "https://graph.microsoft.com" -AsSecureString).Token
        Connect-MgGraph -AccessToken $token -Environment Global

        $response = Get-MgSubscribedSku -All | Format-List

        if ($null -eq $response) {
            Write-Error "Failed to get tenant licenses."
            return
        }
    }
    catch {
        Write-Error "Tenant eligibility for PIM Test failed: $_"
        return
    }
}

function Check-TenantLicenses {
    param (
        [string]$AccessToken
    )

    $headers = @{
        Authorization = "Bearer $AccessToken"
    }

    # Make the API request
    $response = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/subscribedSkus" -Headers $headers

    # Output the raw response for debugging purposes
    Write-Output "Raw Response: $($response | ConvertTo-Json -Depth 10)"

    if ($null -eq $response) {
        Write-Output "No response received."
        return $false
    }

    if ($response.value.Count -eq 0) {
        Write-Output "No subscribed SKUs found."
        return $false
    }

    $requiredLicenses = @("AAD_PREMIUM_P2", "ENTERPRISE_MOBILITY_SECURITY_E5")
    $hasRequiredLicenses = $false

    foreach ($sku in $response.value) {
        if ($sku.skuPartNumber -in $requiredLicenses) {
            $hasRequiredLicenses = $true
            Write-Output "Found required license: $($sku.skuPartNumber)"
        }
    }

    return $hasRequiredLicenses
}