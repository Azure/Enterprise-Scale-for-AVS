function Test-AVS-DiagSetting {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define API endpoint
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/" +
            "providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName,
            $sddcDetails.sddcName
        )

        # Make the request
        $response = Invoke-APIRequest `
                            -method "Get" `
                            -url $apiUrl `
                            -token $token

        # Check the response
        $recommendationType = if ($null -eq $response -or $response.value.Count -eq 0) {
            "NoAVSDiagnostics"
        } elseif (
            $null -eq ($logCategory = $response.value.properties.logs | Where-Object { $_.category -eq "vmwaresyslog" }) -or 
            -not $logCategory.enabled
        ) {
            "NoAVSSysLogDiagnostic"
        }
        

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Error "AVS Diagnostic setting Test failed: $_"
    }
} 