function Get-Public-IP {
    param (
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$privateCloudName,
        [string]$publicIpName,
        [string]$token
    )

    # Define the API endpoint for listing public IP
    $publicIpApiUrl = [string]::Format(
        "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/workloadNetworks/default/publicIPs/{3}?api-version=2023-09-01", 
        $subscriptionId, 
        $resourceGroupName, 
        $privateCloudName,
        $publicIpName
    )

    # Make the API request to see if specified Public IP already exists
    Write-Output "Checking if public IP already exists..."
    $publicIpResponse = Invoke-APIRequest `
        -method "Get" `
        -url $publicIpApiUrl `
        -token $token
    if ($null -eq $publicIpResponse) {
        Write-Error "Failed to list public IP. The response was null."
        return
    }

    # Check if the response contains public IP
    if (-not $publicIpResponse -or -not $publicIpResponse.properties -or -not $publicIpResponse.properties.displayName) {
        Write-Output "No response or specified Public IP does not exist in the the private cloud."
        return $null
    } else {
        # List the public IPs
        return $publicIpResponse.properties.displayName
    }
}