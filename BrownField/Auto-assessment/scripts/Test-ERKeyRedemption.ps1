function Test-ERKeyRedemption {
    param (
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
            "authorizations?api-version=2023-09-01",
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
            if ($response.value.Count -eq 1) {
                $redemption = $response.value[0]
                if ($redemption.properties.provisioningState -ne "Succeeded") {
                    "NoERAuthKeyRedemption"                                
                }
            } else {
                "MultipleERAuthKeyRedemptions"
            }
        } else {
            "NoERAuthKeyRedemption"
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