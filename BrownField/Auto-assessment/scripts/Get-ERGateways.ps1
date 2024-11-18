function Get-ERGateways {
    param (
        [SecureString]$token,
        [string]$subscriptionId
    )
    # Define the API URL to list all ExpressRoute circuits in the subscription
    $circuitsApiUrl = [string]::Format(
        "https://management.azure.com/subscriptions/{0}/" + 
        "providers/Microsoft.Network/virtualNetworkGateways" +
        "?api-version=2024-03-01&$filter=properties.gatewayType eq 'ExpressRoute'",
        $subscriptionId
    )

    # Make the API request to list all ExpressRoute circuits
    $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $circuitsApiUrl `
                        -token $token

    # Process the response
    if ($response -and $response.value -and $response.value.Count -gt 0) {
        return $response.value
    }
}