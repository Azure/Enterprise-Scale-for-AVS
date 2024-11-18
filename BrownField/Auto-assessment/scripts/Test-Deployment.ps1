function Test-Deployment {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get SDDC Details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define the API URL
        $deploymentApiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.Resources/" +
            "deployments/?api-version=2021-04-01",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName
        )

        # Make the API request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $deploymentApiUrl `
                        -token $token

        # Process the response
        if ($response -and $response.value) {
            # Filter the latest 5 successful deployments based on the timestamp
            $successfulDeployments = $response.value | Where-Object { 
                $_.properties.provisioningState -eq "Succeeded" 
            } | Sort-Object -Property properties.timestamp -Descending | Select-Object -First 5
            

            #Get Details of each successful deployment
            $nonAutomatedDeployments = $successfulDeployments | Where-Object {
                -not (Get-Deployment-Details -deployment $_ -token $token)
            }

            if (($nonAutomatedDeployments.Count -gt 2) -or
                ($successfulDeployments.Count -eq $nonAutomatedDeployments.Count)) {
                $Global:recommendations += Get-Recommendation -type "NoAutomatedDeployment" -sddcName $sddcDetails.sddcName
            }
        }
    }
    catch {
        Write-Error "Deployment Test failed: $_"
    }
}

function Get-Deployment-Details {
    param (
        [PSCustomObject]$deployment,
        [SecureString]$token
    )

    # Define the API URL to get details of the current deployment
    $deploymentApiUrl = "https://management.azure.com$($deployment.id)?api-version=2021-04-01"

    # Make the API request to get details of the current deployment
    $response = Invoke-APIRequest `
                    -method "Get" `
                    -url $deploymentApiUrl `
                    -token $token

    # Process the response
    if ($response) {
        #Check the template link
        if ($null -eq $response.properties.templateLink -or $null -eq $response.properties.templateLink.uri) {
            
            return $false
        }
    }
}