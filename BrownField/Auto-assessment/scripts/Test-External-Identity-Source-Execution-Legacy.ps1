. ./Get-AVS-SDDC-Details.ps1
. ./Get-Recommendation.ps1

function Test-External-Identity-Source-Execution-Legacy {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc,
        [string]$scriptExecutionName
    )
    try {
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Define the base API URL
        $baseApiUrl = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}" +
            "/providers/Microsoft.AVS/privateClouds/{2}/scriptExecutions/{3}?api-version=2023-09-01"

        # Construct the URLs
        $scriptExecutionApiUrl = [string]::Format($baseApiUrl, $sddcDetails.subscriptionId, 
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName, 
            $scriptExecutionName)

        $getLogsApiUrl = [string]::Format($baseApiUrl + "/getExecutionLogs", 
            $sddcDetails.subscriptionId, 
            $sddcDetails.resourceGroupName, 
            $sddcDetails.sddcName, 
            $scriptExecutionName)
        
        $counter = 0
        while ($true) {
            $counter++

            # Construct the request body
            $body = @{
                requests = @(
                    @{
                        httpMethod = "GET"
                        name = (New-RandomGuid)
                        requestHeaderDetails = @{ commandName = "VMCP." }
                        url = $scriptExecutionApiUrl
                    },
                    @{
                        content = @("Output", "Error", "Warning", "Information")
                        httpMethod = "POST"
                        name = (New-RandomGuid)
                        requestHeaderDetails = @{ commandName = "VMCP." }
                        url = $getLogsApiUrl
                    }
                )
            } | ConvertTo-Json -Depth 10

            # Make the API request
            $response = Invoke-APIRequest -method "POST" `
                -url "https://management.azure.com/batch?api-version=2020-06-01" `
                -body $body `
                -token $token    

            # Check the response
            if ($response -and $response.responses) {
                $successResponse = $response.responses | Where-Object { $_.httpStatusCode -eq 200 } | Select-Object -First 1
                $status = $successResponse.content?.properties?.provisioningState                                 

                if ($status -eq "Succeeded" -or $status -eq "Failed" -or $counter -eq 10) {
                    if ($status -eq "Succeeded") {
                        Start-SuccessResponse-Processing -response $successResponse -sddcDetails $sddcDetails
                    } else {
                        Write-Host "Get-ExternalIdentitySource commandlet Failed or took too long to complete."
                    }
                    break
                }

                Start-Sleep -Seconds 10
            } else {
                Write-Error "Failed to Test External Identity Source Execution."
                return
            }
        }
    }
    catch {
        Write-Error "Failed to Test External Identity Source Execution: $_"
        return
    }
}

function Start-SuccessResponse-Processing {
    param (
        [PSCustomObject]$response,
        [PSCustomObject]$sddcDetails
    )

    $output = $response.content?.properties?.output
    if ($output.Count -lt 2) {
        $Global:recommendations += Get-Recommendation -type "NoExternalIdentitySource" `
                                         -sddcName $sddcDetails.sddcName
        $Global:recommendations += Get-Recommendation -type "NoCustomUsers" `
                                    -sddcName $sddcDetails.sddcName
        $Global:recommendations += Get-Recommendation -type "NoCustomGroups" `
                                    -sddcName $sddcDetails.sddcName
        $Global:recommendations += Get-Recommendation -type "NoDomainJoin" `
                                -sddcName $sddcDetails.sddcName
    } else {
        $outputString = $output[1]
        $nameValue = Get-FieldValue -inputString $outputString -fieldName "Name"
        if ($nameValue) {
            $Global:recommendations += Get-Recommendation -type "ExternalIdentitySource" -sddcName $sddcDetails.sddcName -externalIdentitySource $nameValue

            $primaryUrlValue = Get-FieldValue -inputString $outputString -fieldName "PrimaryUrl"
            if ($primaryUrlValue) {
                if ($primaryUrlValue -match '^ldap://') {
                    $Global:recommendations += Get-Recommendation -type "LDAPIdentitySource" -sddcName $sddcDetails.sddcName -ldapServer $primaryUrlValue
                } elseif ($primaryUrlValue -match '^ldaps://') {
                    $Global:recommendations += Get-Recommendation -type "LDAPSIdentitySource" -sddcName $sddcDetails.sddcName -ldapServer $primaryUrlValue
                }
            }

            $userBaseDNValue = Get-FieldValue -inputString $outputString -fieldName "UserBaseDN"
            if ($userBaseDNValue -and $userBaseDNValue.Trim().Length -eq 0) {
                $Global:recommendations += Get-Recommendation -type "NoCustomUsers" -sddcName $sddcDetails.sddcName
            }

            $groupBaseDNValue = Get-FieldValue -inputString $outputString -fieldName "GroupBaseDN"
            if ($groupBaseDNValue -and $groupBaseDNValue.Trim().Length -eq 0) {
                $Global:recommendations += Get-Recommendation -type "NoCustomGroups" -sddcName $sddcDetails.sddcName
            }

        } else {
            Write-Host "Status: Name field not found"
        }
    }
}

function Get-FieldValue {
    param (
        [string]$inputString,
        [string]$fieldName
    )

    $match = [regex]::Match($inputString, "$fieldName\s+:\s+(?<value>.+)")
    if ($match.Success) {
        return $match.Groups["value"].Value.Trim()
    }
    return $null
}

function New-RandomGuid {
    return [guid]::NewGuid().ToString()
}