. ./Get-AVS-SDDC-Details.ps1
. ./Get-Recommendation.ps1
function Test-PIM {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define the base API URL
        $apiUrl = [string]::Format(
            "https://management.azure.com/subscriptions/{0}/" +
            "resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}/" +
            "providers/Microsoft.Authorization/roleEligibilitySchedules?api-version=2020-10-01&$filter=atScope()",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName
        )

        #Make the request
        $response = Invoke-APIRequest `
                        -method "Get" `
                        -url $apiUrl `
                        -token $token

        #Process the response
        if ($response -and $response.value -and $response.value.Count -lt 1) {
            $Global:recommendations += Get-Recommendation -type "NoActivePIMRequests" `
                                        -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        $errorMessage = $_.ErrorDetails.Message

        if ($errorMessage -match "AadPremiumLicenseRequired") {
            $Global:recommendations += Get-Recommendation -type "NoPIMLicense"
        }
        else {
            Write-Error "PIM Test failed: $_"
            return
        }
        
    }
}