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
            foreach ($alert in $response.value) {
                if ($alert.properties.enabled -eq $false) {
                    $alertRecommendations += "DisabledServiveHealthAlert"
                }
                if ($alert.properties.actions.actionGroups.Count -eq 0) {
                    $alertRecommendations += "NoRecipientForServiveHealthAlert"
                }
                $conditions = $alert.properties.condition.allOf
                if ($conditions) {
                    foreach ($condition in $conditions) {
                        if ($condition.anyOf) {
                            foreach ($conditionField in $condition.anyOf) {
                                if ($conditionField.field -eq "resourceId" -and $conditionField.equals -eq $scope) {
                                    # Break the loop if the condition is met
                                    break
                                }
                            }
                        }
                    }
                }else {
                    $alertRecommendations += "NoServiveHealthAlert"
                }
            }
            
        }
        else {
            $alertRecommendations += "NoServiveHealthAlert"
        }

        # Add the recommendation
        foreach ($recommendationType in $alertRecommendations | Select-Object -Unique) {
            if (![string]::IsNullOrEmpty($recommendationType)) {
                $Global:recommendations += Get-Recommendation -type $recommendationType `
                    -sddcName $sddc.name
            }
        }
    }
    catch {
        Write-Error "Service Health Alerts Test failed: $_"
    }
}