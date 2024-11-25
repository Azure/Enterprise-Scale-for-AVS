function Test-ServiceHealth-Alert {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {

        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define scope
        $scope = "/subscriptions/$($sddcDetails.subscriptionId)/resourceGroups/$($sddcDetails.resourceGroupName)/providers/Microsoft.AVS/privateClouds/$($sddcDetails.sddcName)"


        # Define API Endpoint
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/" +
            "providers/Microsoft.Insights/activityLogAlerts?api-version=2020-10-01"
            ,
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName
        )

        # Make the request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $apiUrl `
                        -token $token

        # Process the response
        if ($response -and $response.value -and $response.value.Count -gt 0) {
            $conditions = $response.value | Where-Object { $_.properties.condition.allOf.anyOf.field -contains $scope }
            if ($conditions) {
                foreach ($condition in $conditions) {
                    if (-not $alert.properties.enabled) {
                        $metricRecommendations += "DisabledAlert"
                    }
                    if (-not $alert.properties.actions) {
                        $metricRecommendations += "NoRecipientForAlert"
                    }
                    foreach ($criteria in $alert.properties.criteria?.allOf) {
                        if ($criteria.metricName -in $metricsToTrack) {
                        $metricsBeingTracked += $criteria.metricName
                        }
                    }
                }
                if ($metricsBeingTracked.Count -ne $metricsToTrack.Count) {
                    $metricRecommendations += "MissingAlerts"
                }
            }else {
                $metricRecommendations += "NoAlerts"
            }
        }
        else {
            $metricRecommendations += "NoAlerts"
        }

        # Add the recommendation
        foreach ($recommendationType in $metricRecommendations | Select-Object -Unique) {
            if (![string]::IsNullOrEmpty($recommendationType)) {
                $Global:recommendations += Get-Recommendation -type $recommendationType `
                    -sddcName $sddc.name
            }
        }
    }
    catch {
        Write-Error "Alerts Test failed: $_"
    }
}