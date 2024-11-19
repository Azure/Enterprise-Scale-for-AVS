function Get-ERGateway-Connections {
    param (
        [SecureString]$token,
        [string]$subscriptionId
    )
    # Define the API URL to list all ExpressRoute circuits in the subscription
    $connectionsApiUrl = [string]::Format(
        "https://management.azure.com/subscriptions/{0}/" + 
        "providers/Microsoft.Network/connections" +
        "?api-version=2024-03-01&$filter=properties.connectionType eq 'ExpressRoute'" +
        "&properties.provisioningState eq 'Succeeded'",
        $subscriptionId
    )

    # Make the API request to list all ExpressRoute circuits
    $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $connectionsApiUrl `
                        -token $token

    # Process the response
    if ($response -and $response.value -and $response.value.Count -gt 0) {
        return $response.value
    }
}