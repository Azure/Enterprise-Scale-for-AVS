function Test-ClusterNode-Size {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {

        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Set the node and cluster count
        $nodeCount = $sddc.properties.managementCluster.clusterSize
        $clusterCount = 1

        # Define API Endpoint
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/" +
            "providers/Microsoft.AVS/privateClouds/{2}/clusters?api-version=2023-09-01"
            ,
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
        if ($response -and $response.value -and $response.value.Count -gt 0) {
            foreach ($cluster in $response.value) {
                $clusterCount++
                $nodeCount += $cluster.properties.clusterSize
            }
        }

        # Check if the cluster count is above 14 and node count is above 90
        $sizeRecommendations = @()
        if ($clusterCount -gt 14) { $sizeRecommendations += "ClusterCountNearLimit" }
        if ($nodeCount -gt 90) { $sizeRecommendations += "NodeCountNearLimit" }

        # Add the recommendations
        foreach ($recommendationType in $sizeRecommendations) {
            if (![string]::IsNullOrEmpty($recommendationType)) {
                $Global:recommendations += Get-Recommendation -type $recommendationType `
                    -sddcName $sddc.name
            }
        }

    }
    catch {
        Write-Error "Test Cluster Node Size Failed: $_"
    }
}