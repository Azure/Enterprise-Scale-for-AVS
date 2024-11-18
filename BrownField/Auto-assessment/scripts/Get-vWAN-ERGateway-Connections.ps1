function Get-vWAN-ERGateway-Connections {
    param (
        [SecureString]$token,
        [string]$subscriptionId
    )
    # Define the API URL to list all ExpressRoute Gateways in vWAN in the subscription
    $gatewaysApiUrl = [string]::Format(
        "https://management.azure.com/subscriptions/{0}/" + 
        "providers/Microsoft.Network/expressRouteGateways/expressRouteConnections" +
        "?api-version=2024-03-01",
        $subscriptionId
    )

    # Make the API request to list all ExpressRoute circuits
    $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $gatewaysApiUrl `
                        -token $token

    # Process the response
    if ($response -and $response.value -and $response.value.Count -gt 0) {
        return $response.value
    }
}