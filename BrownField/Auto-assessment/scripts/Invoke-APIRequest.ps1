function Convert-SecureStringToPlainText {
    param (
        [System.Security.SecureString]$secureString
    )
    $plainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    )
    return $plainText
}

function Get-Base64AuthInfo {
    param (
        [string]$userName,
        [SecureString]$password
    )

    if ($null -eq $userName) {
        Write-Error "Username is null"
        return $null
    }
    if ($null -eq $password) {
        Write-Error "Password is null"
        return $null
    }

    $plainPassword = Convert-SecureStringToPlainText -secureString $password
    $userName = $userName.Trim()
    $plainPassword = $plainPassword.Trim()

    # Encode credentials
    $base64AuthInfo = [Convert]::ToBase64String(
        [Text.Encoding]::ASCII.GetBytes("${userName}:${plainPassword}")
    )

    return $base64AuthInfo
}

function Invoke-APIRequest {
    param (
        [Parameter(Mandatory = $true)]
        [string]$method,
        [Parameter(Mandatory = $true)]
        [string]$url,
        [securestring]$token = $null,
        [string]$body = $null,
        [string]$avsVcenter = $null,
        [string]$avsvCenteruserName = $null,
        [SecureString]$avsvCenterpassword = $null,
        [string]$vmwareApiSessionId = $null,
        [string]$avsnsxtUrl = $null,
        [string]$avsnsxtUserName = $null,
        [SecureString]$avsnsxtPassword = $null
    )

    try {
        # Get VMware API session ID if vCenter credentials are provided
        if ($avsvCenteruserName -and $avsvCenterpassword) {
            $base64AuthInfo = Get-Base64AuthInfo -userName $avsvCenteruserName -password $avsvCenterpassword
            if ($null -eq $base64AuthInfo) {
                return
            }

            # Define the vmware-api-session-id API endpoint
            $sessionUrl = "${avsVcenter}api/session"
            
            # Make the API request
            $sessionResponse = Invoke-RestMethod -Uri $sessionUrl -Method "Post" -Headers @{ 
                Authorization = ("Basic {0}" -f $base64AuthInfo)
                'Content-Type' = 'application/json'
            } -SkipCertificateCheck

            $vmwareApiSessionId = $sessionResponse.Trim()
        }

        # Get NSX-T base64 auth info if NSX-T credentials are provided
        if ($avsnsxtUserName -and $avsnsxtPassword) {
            $nsxtbase64AuthInfo = Get-Base64AuthInfo -userName $avsnsxtUserName -password $avsnsxtPassword
            if ($null -eq $nsxtbase64AuthInfo) {
                return
            }
        }

        # Prepare headers for the API request
        $headers = @{}
        $headers["Content-Type"] = "application/json"
        
        # Add Bearer Token to the headers if available for Azure API calls
        if ($token) {
            $plaintextToken = Convert-SecureStringToPlainText -secureString $token
            $headers["Authorization"] = "Bearer $plaintextToken"
            $headers["User-Agent"] = "pid-6c1d9c0c-370d-4ab9-9ecc-b8e0ad315cc8"
        }

        # Add VMware API session ID to the headers if available for vCenter API calls
        if ($vmwareApiSessionId) {
            $headers["vmware-api-session-id"] = $vmwareApiSessionId
        }

        # Add NSX-T basic auth header if NSX-T URL is provided for NSX-T API calls
        if ($avsnsxtUserName -and $avsnsxtPassword) {
            $headers["Authorization"] = ("Basic {0}" -f $nsxtbase64AuthInfo)
        }

        # Make the API request
        if ($method -ieq "GET") {
            $response = Invoke-RestMethod -Method $method -Uri $url -Headers $headers
        }
        elseif ($method -ieq "PATCH") {
            $response = Invoke-WebRequest -Method $method -Uri $url -Headers $headers -Body $body
        }
        else {
            $response = Invoke-RestMethod -Method $method -Uri $url -Headers $headers -Body $body
        }
        #Write-Host "Response Object: $response"        
        
        return $response
    }
    catch {
        $errorMessage = $_.ErrorDetails.Message
        if ($errorMessage -match "AadPremiumLicenseRequired") {
            throw $_
        }
        else {
            return $null
        }
        
    }
}