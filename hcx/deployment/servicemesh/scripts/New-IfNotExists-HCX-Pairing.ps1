. .\Invoke-API.ps1
. .\Get-Job-Details.ps1
function New-IfNotExists-HCX-Pairing {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [string]$hcxManager,
        [string]$hcxManagerUserName,
        [SecureString]$hcxManagerPassword
    )
    Write-Host "Checking for existing HCX pairing and creating new if it does not exists..."
    $pairing = $null
    # Check if HCX pairing already exists
    $pairing = Get-HCXPairing -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
        -hcxManager $hcxManager `
        -hcxConnectorUserName $hcxConnectorUserName `
        -hcxConnectorPassword $hcxConnectorPassword

    # Get the first pairing matching name of the HCX Manager
    $pairing = $pairing.data.items | Where-Object { $_.url -eq $hcxManager.TrimEnd('/') } | Select-Object -First 1
    if ($pairing) {
        Write-Host "HCX pairing already exists with HCX Manager '$hcxManager'."
    } else {
        Write-Host "No HCX pairing found with AVS HCX Manager. Creating a new pairing..."
    }

    if ($null -eq $pairing) {
        # Create new HCX pairing
        $newPairing = New-HCXPairing -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword `
            -hcxManager $hcxManager `
            -hcxManagerUserName $hcxManagerUserName `
            -hcxManagerPassword $hcxManagerPassword

        if ($newPairing) {

            # Get Job details
            $jobDetails = Get-Job-Details -jobId $newPairing.jobId `
                -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword

            # Check the status
            while ($null -eq $jobDetails.jobData.endpoint) {
                Write-Host "Waiting for HCX Pairing to complete..."
                Start-Sleep -Seconds 10
                $jobDetails = Get-Job-Details -jobId $newPairing.jobId `
                    -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                    -hcxConnectorUserName $hcxConnectorUserName `
                    -hcxConnectorPassword $hcxConnectorPassword
            }

            if ($jobDetails.jobData.endpoint) {
                $pairing = Get-HCXPairing -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                            -hcxManager $hcxManager `
                            -hcxConnectorUserName $hcxConnectorUserName `
                            -hcxConnectorPassword $hcxConnectorPassword
                $pairing = $pairing.data.items | Where-Object { $_.url -eq $hcxManager.TrimEnd('/') } | Select-Object -First 1
                Write-Host "New Site Pairing '$($pairing.name)' created successfully."
                return $pairing

            } else {
                Write-Error "HCX pairing creation Job failed."
                return $null
            }
        }
    }

    return $pairing
}

function Get-HCXPairing {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxManager,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/cloudConfigs",
            $hcxConnectorServiceUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response -and $response.data -and $response.data.items.Count -gt 0) {
            return $response
        } else {
            return $null
        }
    }
    catch {
        Write-Host "Error retrieving HCX pairing: $_"
    }
}

function New-HCXPairing {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [string]$hcxManager,
        [string]$hcxManagerUserName,
        [SecureString]$hcxManagerPassword
    )

    try {
        # Define API endpoint
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/cloudConfigs",
            $hcxConnectorServiceUrl
        )

        # Define the body of the request
        $body = @{
            remote = @{
                url      = $hcxManager
                username = $hcxManagerUserName
                password = $hcxManagerPassword | ConvertFrom-SecureString -AsPlainText
            }
        }

        # Convert the body to JSON
        $jsonBody = $body | ConvertTo-Json -Depth 10

        # Make the API request
        $response = Invoke-API -method "POST" `
            -url $apiUrl `
            -body $jsonBody `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response.success -eq $true) {
            return $response.data
        } else {
            return $null
        }
    }
    catch {
        Write-Error "Error creating HCX pairing: $_"
    }
}