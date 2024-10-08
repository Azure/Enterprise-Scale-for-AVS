function Get-AVS-Endpoints {
    param (
        [Parameter(Mandatory = $true)]
        [string]$subscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$sddcName,

        [Parameter(Mandatory = $true)]
        [string]$token
    )

    try {
        # Construct the REST API URL
        $avsEndpointuri = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/" +
            "Microsoft.AVS/privateClouds/{2}?api-version=2023-09-01",
            $subscriptionId,
            $resourceGroupName,
            $sddcName
        )

        # Get the AVS SDDC resource using REST API
        $endpointRespose = Invoke-APIRequest -method "Get" -url $avsEndpointuri -Token $token

        if (-not $endpointRespose) {
            throw "Error occurred with '$endpointRespose'."
        }

        # Extract the endpoints
        $endpoints = @{
            vCenter = $endpointRespose.properties.endpoints.vcsa.TrimEnd('/')
            NSXManager = $endpointRespose.properties.endpoints.nsxtManager.TrimEnd('/')
        }

        return $endpoints
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}
