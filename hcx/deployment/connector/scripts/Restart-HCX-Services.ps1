. .\HeaderHelper.ps1
function Restart-HCX-Services {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    
    try {
        Write-Host "Starting HCX service restart process..."

        # Restart App Engine
        $appEngineResult = Invoke-AppEngine-Restart -vCenterPassword $vCenterPassword `
                                -hcxUrl $hcxUrl `
                                -maxRetries 10 `
                                -pollIntervalSeconds 5
        
        if (-not $appEngineResult) {
            Write-Error "Failed to restart App Engine properly."
            return $false
        }

        # Restart Web Component with dependency handling
        $webComponentResult = Invoke-Web-Component-Restart -vCenterPassword $vCenterPassword `
            -hcxUrl $hcxUrl `
            -maxRetries 15 `
            -pollIntervalSeconds 5

        if (-not $webComponentResult) {
            Write-Error "Failed to restart Web Component properly."
            return $false
        }

        Write-Host "HCX services restarted successfully."
    } catch {
        Write-Host "An error occurred while restarting the HCX services: $_"
    }
}

function Invoke-Web-Component-Restart{
     param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl,
        [int]$maxRetries,
        [int]$pollIntervalSeconds
    )
    
    Write-Host "Starting Web Component restart process..."
    
    # Step 1: Stop Plan Engine if it's running (dependency requirement)
    #Write-Host "Checking Plan Engine status..."
    $planEngineStatus = Get-PlanEngine-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
    
    if ($planEngineStatus.result -eq "RUNNING") {
        #Write-Host "Stopping Plan Engine (required for Web Component restart)..."
        Stop-PlanEngine -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
        
        # Wait for Plan Engine to be STOPPED
        $retryCount = 0
        do {
            Start-Sleep -Seconds $pollIntervalSeconds
            $planEngineStatus = Get-PlanEngine-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
            $retryCount++
            
            if ($planEngineStatus.result -eq "STOPPED") {
                #Write-Host "Plan Engine stopped successfully."
                break
            } else {
                if ($retryCount -ge $maxRetries) {
                    Write-Warning "Timeout waiting for Plan Engine to stop. Current status: $($planEngineStatus.result)"
                    return $false
                }
                #Write-Host "Waiting for Plan Engine to stop... (Attempt $retryCount/$maxRetries)"
            }
        } while ($true)
    }
    
    # Step 2: Stop Web Component if it's running
    Write-Host "Checking Web Component status..."
    $webComponentStatus = Get-Web-Component-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
    
    if ($webComponentStatus.result -eq "RUNNING") {
        Write-Host "Stopping Web Component..."
        Stop-Web-Component -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
        
        # Wait for Web Component to be STOPPED
        $retryCount = 0
        do {
            Start-Sleep -Seconds $pollIntervalSeconds
            $webComponentStatus = Get-Web-Component-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
            $retryCount++
            
            if ($webComponentStatus.result -eq "STOPPED") {
                Write-Host "Web Component stopped successfully."
                break
            } else {
                if ($retryCount -ge $maxRetries) {
                    Write-Warning "Timeout waiting for Web Component to stop. Current status: $($webComponentStatus.result)"
                    return $false
                }
                Write-Host "Waiting for Web Component to stop... (Attempt $retryCount/$maxRetries)"
            }
        } while ($true)
    }
    
    # Step 3: Start Web Component
    Write-Host "Starting Web Component again..."
    Start-Web-Component -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
    
    # Wait for Web Component to be RUNNING
    $retryCount = 0
    do {
        Start-Sleep -Seconds $pollIntervalSeconds
        $webComponentStatus = Get-Web-Component-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl  
        $retryCount++
        
        if ($webComponentStatus.result -eq "RUNNING") {
            Write-Host "Web Component is running again."
            break
        } else {
            if ($retryCount -ge $maxRetries) {
                Write-Warning "Timeout waiting for Web Component to start. Current status: $($webComponentStatus.result)"
                return $false
            }
            Write-Host "Waiting for Web Component to start... (Attempt $retryCount/$maxRetries)"
        }
    } while ($true)
    
    # Step 4: Start Plan Engine (now that Web Component is running)
    #Write-Host "Starting Plan Engine..."
    Start-PlanEngine -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    # Wait for Plan Engine to be RUNNING
    $retryCount = 0
    do {
        Start-Sleep -Seconds $pollIntervalSeconds
        $planEngineStatus = Get-PlanEngine-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
        $retryCount++
        
        if ($planEngineStatus.result -eq "RUNNING") {
            #Write-Host "Plan Engine started successfully."
            break
        } else {
            if ($retryCount -ge $maxRetries) {
                Write-Warning "Timeout waiting for Plan Engine to start. Current status: $($planEngineStatus.result)"
                return $false
            }
            #Write-Host "Waiting for Plan Engine to start... (Attempt $retryCount/$maxRetries)"
        }
    } while ($true)
    
    #Write-Host "Web Component restart process completed successfully."
    return $true
}

function Invoke-AppEngine-Restart{
     param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl,
        [int]$maxRetries,
        [int]$pollIntervalSeconds
    )
    
    Write-Host "Starting App Engine restart process..."
    
    # Step 1: Stop App Engine if it's running
    Write-Host "Checking App Engine status..."
    $appEngineStatus = Get-AppEngine-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    if ($appEngineStatus.result -eq "RUNNING") {
        Write-Host "Stopping App Engine..."
        Stop-AppEngine -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
        
        # Step 2: Wait for App Engine to be STOPPED
        $retryCount = 0
        do {
            Start-Sleep -Seconds $pollIntervalSeconds
            $appEngineStatus = Get-AppEngine-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
            $retryCount++
            
            if ($appEngineStatus.result -eq "STOPPED") {
                #Write-Host "App Engine stopped successfully."
                break
            } else {
                if ($retryCount -ge $maxRetries) {
                    Write-Warning "Timeout waiting for App Engine to stop. Current status: $($appEngineStatus.result)"
                    return $false
                }
                Write-Host "Waiting for App Engine to stop... (Attempt $retryCount/$maxRetries)"
            }
        } while ($true)
    }

    # Step 3: Start App Engine
    Write-Host "Starting App Engine again..."
    Start-AppEngine -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    # Step 4: Wait for App Engine to be RUNNING
    $retryCount = 0
    do {
        Start-Sleep -Seconds $pollIntervalSeconds
        $appEngineStatus = Get-AppEngine-Status -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
        $retryCount++

        if ($appEngineStatus.result -eq "RUNNING") {
            Write-Host "App Engine is running again."
            break
        } else {
            if ($retryCount -ge $maxRetries) {
                Write-Warning "Timeout waiting for App Engine to start. Current status: $($appEngineStatus.result)"
                return $false
            }
            Write-Host "Waiting for App Engine to start... (Attempt $retryCount/$maxRetries)"
        }
    } while ($true)
    
    Write-Host "App Engine restart process completed successfully."
    return $true
}

function Get-Web-Component-Status {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/web/status",
        $hcxUrl
    )

    # Make the request to get web component status
    $response = Invoke-WebRequest -method "GET" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        return $response.Content | ConvertFrom-Json
    } else {
        Write-Error "Failed to retrieve Web Component status."
        return $null
    }
}

function Stop-Web-Component {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/web?action=stop",
        $hcxUrl
    )

    # Make the request to stop the web component
    $response = Invoke-WebRequest -method "POST" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        #Write-Host "Web component stopped successfully."
    } else {
        Write-Error "Failed to stop web component."
    }

    return $response

}
function Start-Web-Component {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/web?action=start",
        $hcxUrl
    )

    # Make the request to start the web component
    $response = Invoke-WebRequest -method "POST" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        #Write-Host "Web component started successfully."
    } else {
        Write-Error "Failed to start web component."
    }

    return $response
}

function Get-AppEngine-Status {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/appengine/status",
        $hcxUrl
    )

    # Make the request to get app engine status
    $response = Invoke-WebRequest -method "GET" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        return $response.Content | ConvertFrom-Json
    } else {
        Write-Error "Failed to retrieve App Engine status."
        return $null
    }
}

function Stop-AppEngine {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/appengine?action=stop",
        $hcxUrl
    )

    # Make the request to stop the app engine component
    $response = Invoke-WebRequest -method "POST" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        Write-Host "App Engine component stopped successfully."
    } else {
        Write-Error "Failed to stop App Engine component."
    }

    return $response

}

function Start-AppEngine {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/appengine?action=start",
        $hcxUrl
    )

    # Make the request to start the app engine component
    $response = Invoke-WebRequest -method "POST" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        #Write-Host "App Engine component started successfully."
    } else {
        Write-Error "Failed to start App Engine component."
    }

    return $response
}

function Get-PlanEngine-Status {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/planengine/status",
        $hcxUrl
    )

    # Make the request to get plane engine status
    $response = Invoke-WebRequest -method "GET" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        return $response.Content | ConvertFrom-Json
    } else {
        Write-Error "Failed to retrieve Plan Engine status."
        return $null
    }
}

function Stop-PlanEngine {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/planengine?action=stop",
        $hcxUrl
    )

    # Make the request to stop the plan engine component
    $response = Invoke-WebRequest -method "POST" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        #Write-Host "Plan Engine component stopped successfully."
    } else {
        Write-Error "Failed to stop Plan Engine component."
    }

    return $response

}

function Start-PlanEngine {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )
    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "components/planengine?action=start",
        $hcxUrl
    )

    # Make the request to start the plan engine component
    $response = Invoke-WebRequest -method "POST" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        #Write-Host "Plan Engine component started successfully."
    } else {
        Write-Error "Failed to start Plan Engine component."
    }

    return $response
}