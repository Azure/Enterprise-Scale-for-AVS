. .\Get-AVS-SDDC-Details.ps1
. .\Get-Recommendation.ps1

function Test-vCenter-Password-Rotation {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get the current timestamp
        $currentTimestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

        # Get the timestamp from 90 days ago
        $pastTimestamp = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")

        $filterCondition = "eventTimestamp ge '$pastTimestamp' and " +
                           "eventTimestamp le '$currentTimestamp' and " +
                           "eventChannels eq 'Admin, Operation' and " +
                           "categories eq 'Administrative' and " +
                           "resourceGroupName eq '$($sddcDetails.resourceGroupName)' and " +
                           "resourceId eq '$($sddcDetails.sddcId)' and " +
                           "levels eq 'Informational'"

        $selectCondition = "operationName"

        # URL-encode the $filter and $select variables using System.Net.WebUtility
        $encodedFilter = [System.Net.WebUtility]::UrlEncode($filterCondition)
        $encodedSelect = [System.Net.WebUtility]::UrlEncode($selectCondition)

        # Manually encode the $filter and $select keywords
        $encodedFilterKeyword = [System.Net.WebUtility]::UrlEncode('$filter')
        $encodedSelectKeyword = [System.Net.WebUtility]::UrlEncode('$select')

        # Define the API URL
        $apiUrl = "https://management.azure.com/subscriptions/$($sddcDetails.subscriptionId)/" +
                  "providers/microsoft.insights/eventtypes/management/values" +
                  "?api-version=2017-03-01-preview" +
                  "&$encodedFilterKeyword=$encodedFilter" +
                  "&$encodedSelectKeyword=$encodedSelect"

        # Make the request
        $response = Invoke-APIRequest `
                    -method "Get" `
                    -url $apiUrl `
                    -token $token

        # Process the response
        if ($response -and $response.value -and $response.value.Count -gt 0) {
            # Filter the items to find the one with the desired operationName
            $matchingItem = $response.value | Where-Object { $_.operationName.value -eq "Microsoft.AVS/privateClouds/rotateVcenterPassword/action" } | Select-Object -First 1
        
            # Check if a matching item was found
            if (-not $matchingItem) {
                $Global:recommendations += Get-Recommendation -type "vCenterPasswordRotation" `
                                            -sddcName $sddcDetails.sddcName
            }                    
        }
    }
    catch {
        Write-Error "vCenter Password Rotation Test failed: $_"
        return
    }
}