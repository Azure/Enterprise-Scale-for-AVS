. .\Get-AVS-Credentials.ps1

function Get-AVS-SDDC-Details {
    param (
        [SecureString]$token,
        [string]$subscriptionId,
        [string]$avsSddcName
    )
    try {
        # Define the API endpoint for getting AVS SDDCs
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "providers/Microsoft.AVS/privateClouds?api-version=2023-09-01",
            $subscriptionId
        )

        # Make the API request for AVS credentials
        $response = Invoke-API -method "Get" `
                        -url $apiUrl `
                        -token $token `
                        -AuthType "Bearer" `

        if ($null -eq $response) {
            Write-Error "Failed to get AVS SDDC Details."
            return
        }

        # Filter the AVS SDDCs
        if ($avsSddcName) {
            $response.value = $response.value | Where-Object { $avsSddcName -contains $_.name }
        }

        $sddc = $response.value

        if ($sddc) {
            # Get AVS Credentials
            $avsCredentials = Get-AVS-Credentials -token $token -sddc $sddc

            return @{
                subscriptionId = $sddc.id.split("/")[2]
                resourceGroupName = $sddc.id.split("/")[4]
                sddcName = $sddc.id.split("/")[-1]
                sddcId = $sddc.id
                vCenterUrl = $sddc.properties.endpoints.vcsa
                nsxtUrl = $sddc.properties.endpoints.nsxtManager
                hcxUrl = $sddc.properties.endpoints.hcxCloudManager
                vCenterUserName = $avsCredentials.vCenterUsername
                vCenterPassword = $avsCredentials.vCenterPassword
            }
        }

        return $null
    }
    catch {
        Write-Error "Failed to get AVS SDDC Details: $_"
        return
    }
}