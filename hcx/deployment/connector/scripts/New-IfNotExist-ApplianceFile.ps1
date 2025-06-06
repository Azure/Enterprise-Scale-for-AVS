. .\Invoke-APIRequest.ps1

function New-IfNotExist-ApplianceFile {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryItemID,        
        [string]$applianceFilePath
    )
    try {
        # Define Item Name
        $fileName = $applianceFilePath.Split("\")[-1]

        
        if ($contentLibraryItemID -and -not [string]::IsNullOrWhiteSpace($contentLibraryItemID)) {

            # Get Content Library Item Details
            $contentLibraryItemDetails = Get-LibraryItem-Details -vCenter $vCenter `
                -vCenterUserName $vCenterUserName `
                -vCenterPassword $vCenterPassword `
                -libraryItemID $contentLibraryItemID

            if ($contentLibraryItemDetails.size -gt 0) {
                Write-Host "Content Library Item '$contentLibraryitemName' already has installation file. Skipping upload."
            } 
            else {
                Write-Host "Uploading HCX Installation file."            
                
                # Create Content Library Item Upload Session
                $contentLibraryItemUploadSession = New-LibraryItem-Upload-Session -vCenter $vCenter `
                -vCenterUserName $vCenterUserName `
                -vCenterPassword $vCenterPassword `
                -libraryItemID $contentLibraryItemID
                
                # Get Content Library Item File Upload Session Url
                $contentLibraryItemFileUploadSessionUri = Get-LibraryItem-File-Upload-Url -vCenter $vCenter `
                        -vCenterUserName $vCenterUserName `
                        -vCenterPassword $vCenterPassword `
                        -contentLibraryItemUploadSession $contentLibraryItemUploadSession `
                        -fileName $fileName
                            
                if ([string]::IsNullOrEmpty($contentLibraryItemFileUploadSessionUri)) {
                    throw "Failed to get upload URL from vCenter API"
                }
                
                # Upload the Appliance file
                UploadApplianceFile -uploadUrl $contentLibraryItemFileUploadSessionUri `
                    -filePath $applianceFilePath `
                    -contentLibraryItemUploadSession $contentLibraryItemUploadSession `
                    -vCenter $vCenter `
                    -vCenterUserName $vCenterUserName `
                    -vCenterPassword $vCenterPassword

                #return $contentLibraryItemID
            }
        }
    }
    catch {
        write-Error "Failed to create Content Library: $_"
    }
}

function DownloadISOFile {
    param (
        [string]$url,
        [string]$outputPath
    )

    # Create HttpClient instance
    $httpClient = [System.Net.Http.HttpClient]::new()

    try {
        # Send a GET request to the URL
        $response = $httpClient.GetAsync($url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        $response.EnsureSuccessStatusCode()

        # Get the content stream
        $contentStream = $response.Content.ReadAsStreamAsync().Result

        # Create a file stream to write the content to
        $fileStream = [System.IO.File]::Create($outputPath)

        # Buffer size for reading the content
        $bufferSize = 81920
        $buffer = New-Object byte[] $bufferSize
        $totalBytesRead = 0
        $bytesRead = 0

        # Read the content stream and write to the file stream
        while (($bytesRead = $contentStream.Read($buffer, 0, $bufferSize)) -gt 0) {
            $fileStream.Write($buffer, 0, $bytesRead)
            $totalBytesRead += $bytesRead

            # Display progress
            Write-Progress -Activity "Downloading ISO" -Status "$([math]::Round(($totalBytesRead / $response.Content.Headers.ContentLength.Value) * 100, 2))% Complete" -PercentComplete (($totalBytesRead / $response.Content.Headers.ContentLength.Value) * 100)
        }

        Write-Host "Download complete!"
    } catch {
        Write-Host "An error occurred: $_"
    } finally {
        # Clean up
        $contentStream.Dispose()
        $fileStream.Dispose()
        $httpClient.Dispose()
    }
}

function UploadApplianceFile {
    param (
        [string]$uploadUrl,
        [string]$filePath,
        [string]$contentLibraryItemUploadSession,
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword
    )

    if (-not [System.Uri]::IsWellFormedUriString($uploadUrl, [System.UriKind]::Absolute)) {
        throw "The provided URL is not a valid absolute URI: $uploadUrl"
    }

    # Initialize SSL bypass for self-signed certificates
    Initialize-SSLBypass

    try {
        Write-Host "Starting upload to $uploadUrl"
        Write-Host "File: $filePath"

        # Get file info
        $fileInfo = Get-Item $filePath
        Write-Host "File size: $($fileInfo.Length) bytes ($([math]::Round($fileInfo.Length/1GB, 2)) GB)"

        # Use the same authentication method as Invoke-APIRequest
        $base64AuthInfo = Get-Base64AuthInfo -userName $vCenterUserName -password $vCenterPassword
        if (-not $base64AuthInfo) {
            throw "Failed to generate authentication header"
        }

        # Use Invoke-WebRequest with the same pattern as other working calls
        $headers = @{
            'Authorization' = "Basic $base64AuthInfo"
            'Content-Type' = 'application/octet-stream'
        }

        Write-Host "Starting file upload using Invoke-WebRequest..."
        $uploadStartTime = Get-Date
        
        # Start the upload as a background job to allow progress monitoring
        $uploadJob = Start-Job -ScriptBlock {
            param($url, $file, $headers)
            
            try {
                # Use Invoke-WebRequest for file upload (same SSL bypass as Invoke-RestMethod)
                $response = Invoke-WebRequest -Uri $url -Method Put -InFile $file -Headers $headers -SkipCertificateCheck
                return @{
                    Success = $true
                    StatusCode = $response.StatusCode
                    StatusDescription = $response.StatusDescription
                    ContentLength = $response.Headers.'Content-Length'
                }
            } catch {
                return @{
                    Success = $false
                    Error = $_.Exception.Message
                    ErrorDetails = $_.ErrorDetails.Message
                }
            }
        } -ArgumentList $uploadUrl, $filePath, $headers        # Monitor upload progress with adaptive intervals
        Write-Host "Upload job started (Job ID: $($uploadJob.Id)). Monitoring progress..."
        Write-Host "File being uploaded: $([System.IO.Path]::GetFileName($filePath)) ($([math]::Round($fileInfo.Length/1MB, 1)) MB)" 
        $lastProgressTime = Get-Date
        $progressCheckInterval = 30  # Start with 30 seconds
        $maxInterval = 60  # Maximum interval of 1 minute
        
        do {
            Start-Sleep -Seconds $progressCheckInterval
              # Check if upload job is still running
            $jobState = Get-Job -Id $uploadJob.Id
            $elapsedMinutes = ((Get-Date) - $uploadStartTime).TotalMinutes
            
            # Enhanced progress display based on job state
            if ($jobState.State -eq "Running") {
                Write-Host "Upload in progress | Elapsed: $($elapsedMinutes.ToString('F1')) min | Job: $($jobState.State)" 
            } elseif ($jobState.State -eq "Completed") {
                Write-Host "Upload job finished | Total time: $($elapsedMinutes.ToString('F1')) min | Job: $($jobState.State)" 
            } else {
                Write-Host "Upload status: $($jobState.State) | Elapsed: $($elapsedMinutes.ToString('F1')) min"
            }            # Check upload session status with optimized logging (skip if upload job is already completed)
            if ($jobState.State -eq "Running") {
                try {
                    $sessionStatus = Get-UploadSessionStatus -updateSessionId $contentLibraryItemUploadSession `
                                                            -vCenter $vCenter `
                                                            -vCenterUserName $vCenterUserName `
                                                            -vCenterPassword $vCenterPassword
                
                if ($sessionStatus) {
                    # Create a clean summary without certificate noise
                    $statusSummary = @{
                        state = $sessionStatus.state
                        client_progress = $sessionStatus.client_progress
                        expiration_time = $sessionStatus.expiration_time
                    }                    # Check for actual file progress from VMware API
                    $realProgress = $null
                    $hasFileProgress = $false
                    if ($sessionStatus.files -and $sessionStatus.files.Count -gt 0) {
                        $statusSummary.files_count = $sessionStatus.files.Count
                        foreach ($file in $sessionStatus.files) {                            if ($file.bytes_transferred -and $file.size -and $file.size -gt 0) {
                                $realProgress = ($file.bytes_transferred / $file.size) * 100
                                $bytesTransferredMB = [math]::Round($file.bytes_transferred / 1MB, 1)
                                $totalSizeMB = [math]::Round($file.size / 1MB, 1)
                                
                                Write-Host "VMware progress: $bytesTransferredMB/$totalSizeMB MB ($($realProgress.ToString('F1'))%)" 
                                $hasFileProgress = $true
                            } elseif ($file.name) {
                                # Show file name even if no progress data
                                Write-Host "Processing file: $($file.name)" 
                                $hasFileProgress = $true
                            }
                        }
                    }                    # Show progress information (prefer real progress over estimates)
                    if ($hasFileProgress -and $realProgress -ne $null -and $realProgress -gt 0) {
                        # Use real VMware progress
                        $remainingPercent = 100 - $realProgress
                        $estimatedTimeLeft = if ($realProgress -gt 5) { 
                            [math]::Round(($elapsedMinutes * $remainingPercent) / $realProgress, 1)
                        } else { 
                            "calculating..." 
                        }
                          if ($jobState.State -eq "Running") {
                            Write-Host "Session: $($statusSummary.state) | Real progress: $($realProgress.ToString('F1'))% | ETA: ~$estimatedTimeLeft min" 
                            
                            # Send real progress update to vCenter to sync with Task Console
                            try {
                                $progressUpdate = KeepAliveUploadApplianceFile -updateSessionId $contentLibraryItemUploadSession `
                                                                        -clientProgress ([int]$realProgress) `
                                                                        -vCenter $vCenter `
                                                                        -vCenterUserName $vCenterUserName `
                                                                        -vCenterPassword $vCenterPassword
                                Write-Host "Progress sync sent to vCenter: $([int]$realProgress)%"
                            } catch {
                                Write-Host "Could not sync progress to vCenter: $($_.Exception.Message)"
                            }
                        } else {
                            Write-Host "Session: $($statusSummary.state) | Upload job completed ($($realProgress.ToString('F1'))%)" 
                        }
                    } else {
                        # Fallback to estimated progress when real progress isn't available yet
                        $fileSizeGB = $fileInfo.Length / 1GB
                        $estimatedTotalMinutes = [Math]::Max(1.5, $fileSizeGB * 0.5)  # Estimate 0.5 min per GB minimum
                        $estimatedProgress = [Math]::Min(95, ($elapsedMinutes / $estimatedTotalMinutes) * 100)
                        
                        if ($jobState.State -eq "Running") {
                            Write-Host "Session: $($statusSummary.state) | Est. progress: ~$($estimatedProgress.ToString('F0'))% | ETA: ~$([Math]::Max(0, $estimatedTotalMinutes - $elapsedMinutes).ToString('F1')) min"
                        } else {
                            Write-Host "Session: $($statusSummary.state) | Upload job completed" 
                        }
                    }
                    }
                } catch {
                    Write-Host "Could not check session status: $($_.Exception.Message)"
                }
            } else {
                Write-Host "Upload job completed, skipping session status check"
            }
              # Adaptive interval: increase check interval for longer uploads, or exit early if job is done
            if ($jobState.State -eq "Running") {
                if ($elapsedMinutes -gt 3 -and $progressCheckInterval -lt $maxInterval) {
                    $progressCheckInterval = [Math]::Min($maxInterval, $progressCheckInterval + 15)
                    Write-Host "Adjusted monitoring interval to $progressCheckInterval seconds"
                }
            } else {
                Write-Host "Upload job completed, ending monitoring loop"
                break
            }
            
            $lastProgressTime = Get-Date
            
        } while ($jobState.State -eq "Running")
        
        # Get the upload job result
        $uploadResult = Receive-Job -Job $uploadJob
        Remove-Job -Job $uploadJob
          $uploadEndTime = Get-Date
        $uploadDuration = $uploadEndTime - $uploadStartTime
        Write-Host "Upload job completed in $($uploadDuration.TotalMinutes.ToString('F1')) minutes" 
        
        if ($uploadResult.Success) {
            Write-Output "HCX OVA File Upload completed successfully!"
            #Write-Output "Response Status: $($uploadResult.StatusCode) - $($uploadResult.StatusDescription)"
            
            # Wait a bit more for upload to be fully processed
            Write-Host "Waiting for upload to be fully processed..."
            Start-Sleep -Seconds 10
        } else {
            throw "Upload failed: $($uploadResult.Error). Details: $($uploadResult.ErrorDetails)"
        }        # Now validate the upload with retries
        Write-Host "Validating upload..."
        $maxValidationRetries = 5
        $validationRetryCount = 0
        $validatedResponse = $null
        
        do {
            try {
                $validatedResponse = ValidateUploadApplianceFile -updateSessionId $contentLibraryItemUploadSession `
                                                           -vCenter $vCenter `
                                                           -vCenterUserName $vCenterUserName `
                                                           -vCenterPassword $vCenterPassword
                
                if ($validatedResponse) {
                    # Clean validation response logging
                    $validationSummary = @{
                        has_errors = $validatedResponse.has_errors
                        invalid_files = if ($validatedResponse.invalid_files) { $validatedResponse.invalid_files.Count } else { 0 }
                        missing_files = if ($validatedResponse.missing_files) { $validatedResponse.missing_files.Count } else { 0 }
                    }
                    #Write-Host "Validation result: $($validationSummary | ConvertTo-Json -Compress)" 
                    break
                }
            } catch {
                Write-Warning "Validation attempt $($validationRetryCount + 1) failed: $($_.Exception.Message)"
            }
            
            $validationRetryCount++
            if ($validationRetryCount -lt $maxValidationRetries) {
                Write-Host "Retrying validation in 10 seconds... (Attempt $($validationRetryCount + 1)/$maxValidationRetries)"
                Start-Sleep -Seconds 10
            }
            
        } while ($validationRetryCount -lt $maxValidationRetries)
        
        if ($validatedResponse -and $validatedResponse.has_errors -eq $false) {
            Write-Host "Upload validation successful. Completing upload session..."
            Complete-LibraryItem-Upload-Session -vCenter $vCenter `
                                                -vCenterUserName $vCenterUserName `
                                                -vCenterPassword $vCenterPassword `
                                                -updateSessionId $contentLibraryItemUploadSession
            Write-Host "Upload session completed successfully!"
        } else {
            Write-Warning "Upload validation failed or returned unexpected response. Attempting to complete session anyway..."
            Complete-LibraryItem-Upload-Session -vCenter $vCenter `
                                                -vCenterUserName $vCenterUserName `
                                                -vCenterPassword $vCenterPassword `
                                                -updateSessionId $contentLibraryItemUploadSession
        }
        
    } catch {
        Write-Error "Upload failed: $_"
        throw
    } 
    finally {
        # Reset SSL validation to default behavior
        Reset-SSLValidation
    }
}

function KeepAliveUploadApplianceFile {
    param (
        [string]$updateSessionId,
        [int]$clientProgress,
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword
    )

    # Create API Endpoint to keep the upload session alive
    $keepAliveUploadSessionUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session/{1}?action=keep-alive",
        $vCenter,
        $updateSessionId
    )

    # Define the body for the request
    $body = @{
        client_progress = $clientProgress
    }

    # Convert the body to JSON
    $jsonBody = $body | ConvertTo-Json -Depth 10

    # Make the request to keep the upload session alive
    $response = Invoke-APIRequest -method "Post" `
                      -body $jsonBody `
                      -url $keepAliveUploadSessionUrl `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        return $response
    }
}

function Get-UploadSessionStatus {
    param (
        [string]$updateSessionId,
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword
    )

    # Create API Endpoint to get the upload session status
    $getUploadSessionStatusUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session/{1}",
        $vCenter,
        $updateSessionId
    )

    # Make the request to get the upload session status
    $response = Invoke-APIRequest -method "Get" `
                      -url $getUploadSessionStatusUrl `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        return $response
    }
}

function ValidateUploadApplianceFile {
    param (
        [string]$updateSessionId,
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword
    )

    # Create API Endpoint to validate the upload session
    $validateUploadSessionUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session/{1}/file?action=validate",
        $vCenter,
        $updateSessionId
    )

    # Make the request to validate the upload session
    $response = Invoke-APIRequest -method "Post" `
                      -url $validateUploadSessionUrl `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        return $response
    }
}

function CompleteUploadApplianceFile {
    param (
        [string]$updateSessionId
    )

    # Create API Endpoint to keep the upload session alive
    $validateUploadSessionUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session/{1}?action=complete",
        ${vCenter},
        $updateSessionId
    )

    # Make the request to keep the upload session alive
    $response= Invoke-APIRequest -method "Post" `
                      -url $validateUploadSessionUrl `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        return $response
    }

}

function Get-LibraryItem-Details {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$libraryItemID
    )

    # Create API Endpoint to get Content Library Items
    $getContentLibraryItemDetailsUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/{1}",
        ${vCenter},
        $libraryItemID
    )

    # Make the request
    $response= Invoke-APIRequest -method "Get" `
                      -url $getContentLibraryItemDetailsUrl `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        return $response
    }
}

function New-LibraryItem-Upload-Session {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$libraryItemID
    )

    Write-Host "Creating upload session."

    # Create API Endpoint to create a new Content Library Item Upload Session
    $createLibraryItemUploadSessionUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session",
        ${vCenter}
    )
    
    # Define the body for the request
    $body = @{
        library_item_id = $libraryItemID
    }
    
    # Convert the body to JSON
    $jsonBody = $body | ConvertTo-Json -Depth 10

    # Make the request to create the upload session
    $response = Invoke-APIRequest -method "Post" `
                      -url $createLibraryItemUploadSessionUrl `
                      -body $jsonBody `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        if ($response -is [string] -and -not [string]::IsNullOrWhiteSpace($response)) {
            
            return $response
        } elseif ($response -is [object] -and $response.id) {
            
            return $response.id
        } else {
            
            return $response
        }
    } else {
        Write-Error "Failed to create upload session - no response received"
        return $null
    }
}

function Complete-LibraryItem-Upload-Session {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$updateSessionId
    )

    # Create API Endpoint to complete Content Library Item
    $completeLibraryItemUploadSessionUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session/{1}?action=complete",
        ${vCenter},
        $updateSessionId
    )

    # Make the request to complete update session
    $response= Invoke-APIRequest -method "Post" `
                      -url $completeLibraryItemUploadSessionUrl `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        return $response
    }
}


function Get-LibraryItem-File-Upload-Url {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryItemUploadSession,
        [string]$fileName
    )

    # Create API Endpoint to create a new Content Library Item
    $createFileUploadSessionUrl = [string]::Format(
        "{0}" +
        "api/content/library/item/update-session/{1}/file",
        ${vCenter},
        $contentLibraryItemUploadSession
    )
    
    # Define the body for the request
    $body = @{
        name = $fileName
        source_type = "PUSH"
    }
    
    # Convert the body to JSON
    $jsonBody = $body | ConvertTo-Json -Depth 10    # Make the request to create the Content Library
    $response= Invoke-APIRequest -method "Post" `
                      -url $createFileUploadSessionUrl `
                      -body $jsonBody `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        if ($response.upload_endpoint) {

        } else {
            Write-Host "No upload_endpoint in response. Full response: $($response | ConvertTo-Json -Depth 5)"
        }
        return $response.upload_endpoint.uri
    } else {
        Write-Host "No response received from upload endpoint API call"
        return $null
    }
}

function Initialize-SSLBypass {
    <#
    .SYNOPSIS
    Initialize SSL certificate bypass for self-signed certificates
    .DESCRIPTION
    This function configures PowerShell to bypass SSL certificate validation
    for environments using self-signed certificates like vCenter
    #>
    
    #Write-Host "Initializing SSL certificate bypass for self-signed certificates..."
    
    try {
        # Configure TLS protocols - handle both .NET Framework and .NET Core
        try {
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13
        } catch {
            # Fallback for systems that don't support TLS 1.3
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        }
        
        # Bypass SSL certificate validation globally for .NET Framework WebRequest/WebClient
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        
        # For older .NET Framework compatibility, try to set CertificatePolicy if the interface exists
        try {
            if (-not ("TrustAllCertsPolicy" -as [type])) {
                $TrustAllCertsPolicy = @"
using System.Net;
using System.Security.Cryptography.X509Certificates;

public class TrustAllCertsPolicy : System.Net.ICertificatePolicy {
    public bool CheckValidationResult(
        System.Net.ServicePoint srvPoint, 
        System.Security.Cryptography.X509Certificates.X509Certificate certificate,
        System.Net.WebRequest request, 
        int certificateProblem) {
        return true;
    }
}
"@
                Add-Type -TypeDefinition $TrustAllCertsPolicy -ErrorAction SilentlyContinue
                if ("TrustAllCertsPolicy" -as [type]) {
                    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
                    
                }
            }
        } catch {
            # ICertificatePolicy not available in .NET Core/5+, which is expected and OK
            
        }
        
        # Test if the SSL bypass is working
        #Write-Host "SSL certificate bypass configured successfully"
    } catch {
        Write-Warning "Failed to initialize SSL bypass: $_"
        Write-Warning "Exception type: $($_.Exception.GetType().FullName)"
        return $false
    }
}

function Reset-SSLValidation {
    <#
    .SYNOPSIS
    Reset SSL certificate validation to default behavior
    .DESCRIPTION
    This function restores default SSL certificate validation behavior
    #>
    
    try {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
        
        # Only try to reset CertificatePolicy if it exists (older .NET Framework)
        try {
            if ([System.Net.ServicePointManager] | Get-Member -Name "CertificatePolicy" -MemberType Property) {
                [System.Net.ServicePointManager]::CertificatePolicy = $null
            }
        } catch {
            # CertificatePolicy property doesn't exist in .NET Core/5+, which is fine
        }
        
    } catch {
        Write-Warning "Failed to reset SSL validation: $_"
    }
}