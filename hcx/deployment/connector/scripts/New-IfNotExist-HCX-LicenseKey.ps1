. .\Invoke-APIRequest.ps1
. .\HeaderHelper.ps1

function New-IfNotExist-HCX-LicenseKey {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl,
        [string]$hcxLicenseKey
    )

    # Check if HCX License Key already exists
    $existingKey = Get-HCX-LicenseKey -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    if (-not $existingKey) {
        New-HCX-LicenseKey -vCenterPassword $vCenterPassword `
            -hcxUrl $hcxUrl `
            -hcxLicenseKey $hcxLicenseKey
    }
}

function Get-HCX-LicenseKey {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )

    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "api/admin/licenses",
        $hcxUrl
    )

    # Make the request to get License Key
    $response = Invoke-WebRequest -method "GET" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        $content = $response.Content | ConvertFrom-Json
        if ($content.licenses.Count -gt 0) {
            Write-Host "HCX License Key already exists. Skipping creation."
            return $content.licenses
        }
    } else {
        Write-Error "Failed to retrieve HCX License Key."
        return $null
    }
}

function New-HCX-LicenseKey {
    param (
            [SecureString]$vCenterPassword,
            [string]$hcxUrl,
            [string]$hcxLicenseKey
        )    try {

        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/licenses/activation",
            $hcxUrl
        )    
        
        # Define the body for vCenter configuration
        $body = @{
            "url" = "https://connect.hcx.vmware.com"
            "licenseKey" = $hcxLicenseKey
        }

        # Convert the body to JSON
        $jsonBody = $body | ConvertTo-Json -Depth 10        
        
        # Make the request
        $response = Invoke-WebRequest -method "POST" `
            -Uri $apiUrl `
            -Body $jsonBody `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            Get-New-LicenseKey-Job-Status -vCenterPassword $vCenterPassword `
                -hcxUrl $hcxUrl `
                -licenseKeyJobID ($response.Content | ConvertFrom-Json).jobId
        }
    }
    catch {
        Write-Error "HCX License Key configuration failed: $_"
    }
}

function Get-New-LicenseKey-Job-Status {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl,
        [string]$licenseKeyJobID,
        [int]$TimeoutMinutes = 10,
        [int]$PollIntervalSeconds = 10    )

    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "api/admin/licenses/status/{1}",
        $hcxUrl,
        $licenseKeyJobID
    )

    # Set timeout
    $timeout = (Get-Date).AddMinutes($TimeoutMinutes)
    $finalStatus = $null

    Write-Host "Polling HCX License Key activation status (timeout: $TimeoutMinutes minutes)..."

    do {
        try {
            # Make the request to get License Key status
            $response = Invoke-WebRequest -method "GET" `
                -Uri $apiUrl `
                -Headers $headers `
                -SkipCertificateCheck

            if ($response) {
                $content = $response.Content | ConvertFrom-Json
                $currentStatus = $content.status

                if ($currentStatus -eq 'COMPLETED') {
                    Write-Host "HCX License Key has been successfully activated."
                    break
                } elseif ($currentStatus -eq 'FAILED') {
                    Write-Error "HCX License Key activation failed: $($content.message)"
                    break
                } else {
                    Write-Host "HCX License Key activation in progress. Status: $currentStatus - Checking again in $PollIntervalSeconds seconds..."
                    Start-Sleep -Seconds $PollIntervalSeconds
                }
            } else {
                Write-Warning "No response received. Retrying in $PollIntervalSeconds seconds..."
                Start-Sleep -Seconds $PollIntervalSeconds
            }
        }
        catch {
            Write-Warning "Error checking status: $($_.Exception.Message). Retrying in $PollIntervalSeconds seconds..."
            Start-Sleep -Seconds $PollIntervalSeconds
        }

        # Check if we've exceeded the timeout
        if ((Get-Date) -gt $timeout) {
            Write-Error "Timeout reached ($TimeoutMinutes minutes). HCX License Key activation status check aborted."
            return $null
        }

    } while ($true)
}