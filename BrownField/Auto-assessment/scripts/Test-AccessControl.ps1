function Test-AccessControl {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define  API Endpoint
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/" +
            "providers/Microsoft.Authorization/roleAssignments?api-version=2022-04-01"
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
        if ($response) {
            $rolesToCheck = @(
            "8e3af657-a8ff-443c-a75c-2fe8c4bcb635",  # Owner
            "b24988ac-6180-42a0-ab88-20f7382dd24c",  # Contributor
            "e8e8a5b6-3b5e-4c3a-8b5b-7a4b6b5b6b5b"   # User Access Administrator
            )

            $scopePath = "/subscriptions/$($sddcDetails.subscriptionId)/resourceGroups/$($sddcDetails.resourceGroupName)/providers/Microsoft.AVS/privateClouds/$($sddcDetails.sddcName)"

            $roleAssignments = $response.value | Where-Object {
            $rolesToCheck -contains $_.properties.roleDefinitionId.Split("/")[-1]
            }

            $directAssignments = $roleAssignments | Where-Object {
            $_.properties.scope -eq $scopePath
            }

            $inheritedAssignments = $roleAssignments | Where-Object {
            $_.properties.scope -ne $scopePath
            }

            if ($directAssignments.Count -gt 1 -or $inheritedAssignments.Count -gt 1) {
            $recommendationType = "AccessControl"
            }
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddc.name
        }
    }
    catch {
        Write-Error "Access Control Test failed: $_"
    }
}