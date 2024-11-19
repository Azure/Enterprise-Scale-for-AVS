function Test-DNS {
    param(
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define the API URL
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/" +
            "workloadNetworks/default/dnsZones?api-version=2023-09-01",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName
        )

        # Make the request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $apiUrl `
                        -token $token

        # Process the response
        $recommendatioType = if ($response -and $response.value -and $response.value.Count -gt 0) {
            if ($response.value.Count -eq 1) {
                "DefaultDNSZone"
            }
            elseif ($response.value.Count -gt 1) {
                "CustomDNSZone"
            }
        }
        
        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendatioType)) {
            $Global:recommendations += Get-Recommendation -type $recommendatioType `
                                                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Error "DNS Test failed: $_"
    }
}