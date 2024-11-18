. .\Get-AVS-SDDC-Details.ps1
. .\Test-External-Identity-Source-Execution-Legacy.ps1

function Test-External-Identity-Source-Legacy {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define the base API URL
        $baseApiUrl = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}" +
            "/providers/Microsoft.AVS/privateClouds/{2}/scriptExecutions/{3}?api-version=2023-09-01"

        # Generate script execution name
        $scriptExecutionName = "Get-ExternalIdentitySources-Exec-AVSLZChecker-" + (New-RandomSequence)

        # Construct the script execution API URL
        $scriptExecutionApiUrl = [string]::Format($baseApiUrl, $sddcDetails.subscriptionId, 
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName, 
            $scriptExecutionName)

        # Construct the script cmdlet ID
        $scriptCmdletId = [string]::Format(
            "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.AVS/privateClouds/{2}" +
            "/scriptPackages/Microsoft.AVS.Management@7.0.153/scriptCmdlets/Get-ExternalIdentitySources",
            $sddcDetails.subscriptionId,
            $sddcDetails.resourceGroupName,
            $sddcDetails.sddcName
        )

        # Construct the request body
        $body = @{
            requests = @(
                @{
                    content = @{
                        properties = @{
                            scriptCmdletId = $scriptCmdletId
                            parameters = @()
                            hiddenParameters = @()
                            timeout = "PT3M"
                            retention = "P60D"
                        }
                    }
                    httpMethod = "PUT"
                    name = (New-RandomGuid)
                    requestHeaderDetails = @{
                        commandName = "VMCP."
                    }
                    url = $scriptExecutionApiUrl
                }
            )
        } | ConvertTo-Json -Depth 10

        # Make the API request
        $response = Invoke-APIRequest -method "POST" `
            -url "https://management.azure.com/batch?api-version=2020-06-01" `
            -body $body `
            -token $token

        # Check the response
        $isSuccess = $response.responses `
                        | Where-Object { $_.httpStatusCode -eq 201 } `
                        | ForEach-Object { $true } `
                        | Select-Object -First 1

        if ($isSuccess) {
            Test-External-Identity-Source-Execution-Legacy -token $token `
                            -sddc $sddc `
                            -scriptExecutionName $scriptExecutionName
        } else {
            Write-Error "External Identity Source Test failed."
        }
    }
    catch {
        Write-Error "External Identity Source Test failed: $_"
        return
    }
}

function New-RandomGuid {
    return [guid]::NewGuid().ToString()
}

function New-RandomSequence {
    # Generate a random 3 digit number
    $random = Get-Random -Minimum 100 -Maximum 999
    return $random
}