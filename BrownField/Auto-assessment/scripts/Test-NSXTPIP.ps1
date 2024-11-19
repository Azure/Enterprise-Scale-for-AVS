function Test-NSXTPIP {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc
        
        # Define the API URL
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/" +
            "providers/Microsoft.AVS/privateClouds/{2}/workloadNetworks/default/" +
            "publicIPs?api-version=2023-09-01",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName
        )

        # Make the request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $apiUrl `
                        -token $token

        # Determine the recommendation type
        $recommendationType = if ($response -and $response.value -and $response.value.Count -gt 0) {
            "NSXTPIP"
        } else {
            "ManagedSNAT"
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) 
        { $Global:recommendations += Get-Recommendation -type $recommendationType `
                                            -sddcName $sddcDetails.sddcName 
        }
    }
    catch {
        Write-Error "GlobalReach Test failed: $_"
    }
}