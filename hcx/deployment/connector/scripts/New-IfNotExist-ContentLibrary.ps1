. .\Get-DatastoreID.ps1
. .\Invoke-APIRequest.ps1

function New-IfNotExist-ContentLibrary {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$datastoreName,
        [string]$contentLibraryName
    )
    try {
        # Get the Content Library
        $contentLibraryID = Get-ContentLibrary -vCenter $vCenter `
                                                -vCenterUserName $vCenterUserName `
                                                -vCenterPassword $vCenterPassword `
                                                -contentLibraryName $contentLibraryName
        
        # If the content library does not exist, create it
        if (-not $contentLibraryID) {
            $contentLibraryID = New-ContentLibrary -vCenter $vCenter `
                                    -vCenterUserName $vCenterUserName `
                                    -vCenterPassword $vCenterPassword `
                                    -contentLibraryName $contentLibraryName `
                                    -datastoreName $datastoreName
        }else {
            Write-Host "Content Library '$contentLibraryName' already exists. Skipping creation."
        }

        # Return the Content Library ID
        return $contentLibraryID
    }
    catch {
        write-Error "Failed to create Content Library: $_"
    }
}

function Get-ContentLibrary {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryName
    )
      # Create API Endpoint to filter the Content Library based on name

    $contentLibraryUrl = [string]::Format(
        "{0}" +
        "api/content/local-library",
        ${vCenter}
    )
    
    # Make the request
    $response = Invoke-APIRequest -method "Get" `
                                      -url $contentLibraryUrl `
                                      -vCenter $vCenter `
                                      -vCenterUserName $vCenterUserName `
                                      -vCenterPassword $vCenterPassword
    
    # Process the response to find the Content Library
    if ($response) {
        foreach ($library in $response) {
            # Get the Content Library name
            $libraryName = Get-LibaryName -vCenter $vCenter `
                                            -vCenterUserName $vCenterUserName `
                                            -vCenterPassword $vCenterPassword `
                                            -libraryIdentifier $library
            
            
            # Check if the Content Library name matches the provided name
            if ($libraryName -eq $contentLibraryName) {
                return $library
            }
        }
        Write-Host "No matching content library found"
    }
    
    return $null
}

function New-ContentLibrary {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryName,
        [string]$datastoreName
    )
    

    # Get Datastore ID
    $datastoreID = Get-DatastoreID -vCenter $vCenter `
                                    -vCenterUserName $vCenterUserName `
                                    -vCenterPassword $vCenterPassword `
                                    -datastoreName $datastoreName

    if (-not $datastoreID) {
        Write-Host "Datastore '$datastoreName' not found."
        return $null
    }

    # Create API Endpoint to create a new Content Library
    $createContentLibraryUrl = [string]::Format(
        "{0}" +
        "api/content/local-library",
        ${vCenter}
    )
    
    # Define the body for the request
    $body = @{
        name = $contentLibraryName
        type = "LOCAL"
        storage_backings = @(
            @{
                type = "DATASTORE"
                datastore_id = $datastoreID
            }
        )
    }
    
    # Convert the body to JSON
    $jsonBody = $body | ConvertTo-Json -Depth 10
    
    # Make the request to create the Content Library
    $response = Invoke-APIRequest -method "Post" `
                      -url $createContentLibraryUrl `
                      -body $jsonBody `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($response) {
        Write-Host "Content Library '$contentLibraryName' created successfully."
        return $response
    }
}

function Get-LibaryName {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$libraryIdentifier
    )
        
        # Create API Endpoint to get the Content Library name
        $contentLibraryUrl = [string]::Format(
            "{0}" +
            "api/content/local-library/{1}",
            $vCenter,
            $libraryIdentifier
        )
        
        # Make the request
        $response = Invoke-APIRequest -method "Get" `
                                        -url $contentLibraryUrl `
                                        -vCenter $vCenter `
                                        -vCenterUserName $vCenterUserName `
                                        -vCenterPassword $vCenterPassword
        
        # Process the response to find the Content Library name
        if ($response) {
            return $response.name
        }
}