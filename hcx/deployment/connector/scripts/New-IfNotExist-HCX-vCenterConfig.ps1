. .\Invoke-APIRequest.ps1
. .\HeaderHelper.ps1

function New-IfNotExist-HCX-vCenterConfig {
    param (
        [string]$vCenter,
            [string]$vCenterUserName,
            [SecureString]$vCenterPassword,
            [string]$hcxUrl
    )
    
    # Check if HCX vCenter configuration already exists
    $existingConfig = Get-HCX-vCenterConfig -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    if (-not $existingConfig) {
        New-HCX-vCenterConfig -vCenter $vCenter `
            -vCenterUserName $vCenterUserName `
            -vCenterPassword $vCenterPassword `
            -hcxUrl $hcxUrl
    }
}

function Get-HCX-vCenterConfig {
    param (    
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    
        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
            
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/vcenter",
            $hcxUrl
        )

        # Make the request to get vCenter configuration
        $response = Invoke-WebRequest -method "GET" `
            -Uri $apiUrl `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            $content = $response.Content | ConvertFrom-Json
            if ($content.data.items) {
                Write-Host "HCX vCenter configuration already exists. Skipping creation."
                return $content.data.items
            }
        } else {
            Write-Error "Failed to retrieve HCX vCenter configuration."
            return $null
        }
}

function New-HCX-vCenterConfig {
    param (
            [string]$vCenter,
            [string]$vCenterUserName,
            [SecureString]$vCenterPassword,
            [string]$hcxUrl
        )
    try {

        # Get vCenter Certificate
        $vCenterCertificate = Get-vCenterCertificate -vCenterUrl $vCenter

        # Import the vCenter Certificate to HCX
        if ($vCenterCertificate -and $vCenterCertificate.PEM) {
            Import-Certificate -hcxUrl $hcxUrl `
                -vCenterPassword $vCenterPassword `
                -PEMcertificate $vCenterCertificate.PEM
        }

        # Remove trailing slash from vCenter URL if it exists        if ($vCenter.EndsWith('/')) {
        $vCenter = $vCenter.TrimEnd('/')

        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/vcenter",
            $hcxUrl
        )    
        
        # Define the body for vCenter configuration
        # Convert password to plain text and then Base64 encode for HCX API compatibility
        $plainTextPassword = Convert-SecureStringToPlainText -secureString $vCenterPassword
        $encodedPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($plainTextPassword))
        
        $body = @{
            data = @{
                items = @(
                    @{
                        config = @{
                            url = $vCenter
                            userName = $vCenterUserName
                            password = $encodedPassword
                        }
                    }
                )
            }
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
            Write-Host "HCX vCenter configuration completed successfully."
        }
    }
    catch {
        Write-Error "HCX vCenter configuration failed: $_"
    }
}

function Get-vCenterCertificate {
    param (
        [string]$vCenterUrl,
        [int]$Port = 443
    )
    
    try {
        # Parse the URL to get the hostname
        $uri = [System.Uri]$vCenterUrl
        $hostname = $uri.Host
        
        # Create a TCP client to connect to the vCenter
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($hostname, $Port)
        
        # Create SSL stream
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, {$true})
        
        # Authenticate as client (ignore certificate validation errors)
        $sslStream.AuthenticateAsClient($hostname)
        
        # Get the remote certificate
        $remoteCertificate = $sslStream.RemoteCertificate
        
        # Convert to X509Certificate2 for better handling
        $x509Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($remoteCertificate)
        
        # Export as PEM format
        $certBytes = $x509Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
        $certBase64 = [System.Convert]::ToBase64String($certBytes)
        
        # Format as PEM
        $pemCertificate = "-----BEGIN CERTIFICATE-----`n"
        for ($i = 0; $i -lt $certBase64.Length; $i += 64) {
            $line = $certBase64.Substring($i, [Math]::Min(64, $certBase64.Length - $i))
            $pemCertificate += "$line`n"
        }
        $pemCertificate += "-----END CERTIFICATE-----"
        
        # Clean up
        $sslStream.Close()
        $tcpClient.Close()
        
        return @{
            PEM = $pemCertificate
            Base64 = $certBase64
            Certificate = $x509Certificate
        }
    }
    catch {
        Write-Error "Failed to extract certificate from vCenter: $_"
        return $null
    }
}

function Import-Certificate {
    param (
        [string]$hcxUrl,
        [SecureString]$vCenterPassword,
        [string]$PEMcertificate
    )
      try {
        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/certificates",
            $hcxUrl
        )    
        
        # Define the body
        $body = @{
            certificate = $PEMcertificate
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
            Write-Host "vCenter Certificate imported in HCX successfully."
        }
    }
    catch {
        Write-Error "Failed to import certificate: $_"
    }
}