function Install-RequiredModule {
    param (
        [string]$moduleName
    )

    # Check if the module is already installed
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Output "$moduleName module not found. Installing..."
        Install-Module -Name $moduleName -AllowClobber -Scope CurrentUser -Force
        Write-Output "$moduleName module installed successfully!"
    } else {
        Write-Output "$moduleName module is already installed."
    }

    # Import the module if not already imported
    if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
        Write-Output "Importing module $moduleName..."
        Import-Module -Name $moduleName -ErrorAction Stop -Verbose
    } else {
        Write-Output "Module $moduleName is already imported."
    }
}

function Install-IfNotExist-RequiredModules {
    # Check and install required modules
    Install-RequiredModule -moduleName Az.Accounts
}