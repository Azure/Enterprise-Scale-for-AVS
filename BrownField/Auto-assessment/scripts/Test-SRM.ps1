function Test-SRM {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {

        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define API Endpoint
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/" +
            "Microsoft.AVS/privateClouds/{2}/addons/srm?api-version=2023-09-01",
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
        if ($response) {
            if ($response.properties.provisioningState -ne "Succeeded") {
                $recommendationType = "SRMNotProvisioned"
            }
        } else {
            $recommendationType = "SRMNotProvisioned"
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "SRM Test failed: $_"
    }
}