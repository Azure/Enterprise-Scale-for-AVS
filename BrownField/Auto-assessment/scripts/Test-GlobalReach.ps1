function Test-GlobalReach {
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
            "globalReachConnections?api-version=2023-09-01",
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
                $connection = $response.value[0]
                if ($connection.properties.circuitConnectionStatus -ne "Connected") {
                    "NoGlobalReachConnections"
                } else {
                    "SingleGlobalReachConnection"
                }
            } else {
                "MultipleGlobalReachConnections"
            }
        } else {
            "NoGlobalReachConnections"
        }

        # Add the recommendation
        $Global:recommendations += Get-Recommendation -type $recommendationType -sddcName $sddcDetails.sddcName
    }
    catch {
        Write-Error "GlobalReach Test failed: $_"
    }
}