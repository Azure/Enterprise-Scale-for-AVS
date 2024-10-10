function New-IfNotExist-PublicIP {
    param (
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$privateCloudName,
        [string]$publicIpName,
        [int]$numberOfPublicIPs = 1,
        [string]$token
    )

    try {
        # Define the API endpoint for listing public IP
        $publicIpApiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/workloadNetworks/default/publicIPs/{3}?api-version=2023-09-01", 
            $subscriptionId, 
            $resourceGroupName, 
            $privateCloudName,
            $publicIpName
        )

        # Make the API request to see if specified Public IP already exists
        Write-Host "Checking if public IP already exists..."
        $publicIpResponse = Invoke-APIRequest `
            -method "Get" `
            -url $publicIpApiUrl `
            -token $token

        # Check if the response contains public IP
        if ($null -eq $publicIpResponse -or -not $publicIpResponse -or -not $publicIpResponse.properties -or -not $publicIpResponse.properties.displayName) {
            Write-Host "No response or specified Public IP does not exist in the the private cloud."
            
            New-PublicIP -subscriptionId $subscriptionId `
            -resourceGroupName $resourceGroupName `
            -privateCloudName $privateCloudName `
            -publicIpName $publicIpName `
            -numberOfPublicIPs $numberOfPublicIPs `
            -token $token

        } else {
            # List the public IPs
            Write-Host "Public IP '$($publicIpResponse.properties.displayName)' already exists"
            return $publicIpResponse.properties.publicIPBlock.Split("/")[0].Trim()
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}

function New-PublicIP {
    param (
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$privateCloudName,
        [string]$publicIpName,
        [int]$numberOfPublicIPs,
        [string]$token
    )

    try {
        Write-Host "No public IPs found. Creating a new public IP..."

        $newPublicIpUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/workloadNetworks/default/publicIPs/{3}?api-version=2023-09-01", 
            $subscriptionId, 
            $resourceGroupName, 
            $privateCloudName, 
            $publicIpName
        )
        
        $body = @{
            properties = @{
                displayName = $publicIpName
                numberOfPublicIPs = $numberOfPublicIPs
            }
        }

        $response = Invoke-APIRequest -method "Put" `
                                      -url $newPublicIpUrl `
                                      -token $token `
                                      -body ($body | ConvertTo-Json -Depth 10)

        if ($null -eq $response -or 
            -not $response -or 
            -not $response.properties -or 
            -not $response.properties.publicIPBlock) {
        Write-Error "Failed to create the public IP"
        }
        else {
            Write-Host "Created Public IP address: $response.properties.publicIPBlock.Split("/")[0].Trim()"
            return $response.properties.publicIPBlock.Split("/")[0].Trim()
        }
        
    } catch {
        Write-Error "An error occurred while creating the public IP: $_"
    }
}