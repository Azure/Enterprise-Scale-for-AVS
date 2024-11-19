function Get-AVS-SDDCs {
    param (
        [SecureString]$token,
        [string]$subscriptionId,
        [System.Object[]]$namesofSddcsToTest
    )
    try {
        # Define the API endpoint for getting AVS SDDCs
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "providers/Microsoft.AVS/privateClouds?api-version=2023-09-01",
            $subscriptionId
        )

        # Make the API request for AVS credentials
        Write-Host "Getting all AVS SDDCs..."
        $response = Invoke-APIRequest -method "Get" `
                            -url $apiUrl `
                            -token $token

        if ($null -eq $response) {
            Write-Error "Failed to get AVS SDDCs."
            return
        }

        # Filter the AVS SDDCs
        if ($namesofSddcsToTest.Count -gt 0) {
            $response.value = $response.value | Where-Object { $namesofSddcsToTest -contains $_.name }
        }

        return $response.value
    }
    catch {
        Write-Error "Failed to get AVS SDDCs: $_"
        return
    }
}