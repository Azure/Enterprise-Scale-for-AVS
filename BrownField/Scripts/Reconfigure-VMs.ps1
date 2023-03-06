# Update-Existing-VMs-CPU-Memory-StoragePolicy

# Load VMware PowerCLI module
Import-Module VMware.PowerCLI

# Connect to vCenter Server
Connect-VIServer vcenter.example.com

# Read CSV file
$vmConfig = Import-Csv "C:\VM_Config.csv"

# Iterate through each row of the CSV file
foreach ($row in $vmConfig) {
    # Get the VM by name
    $vm = Get-VM -Name $row.VMName -ErrorAction SilentlyContinue
    if ($vm) {
        # Reconfigure the VM
        $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $spec.NumCoresPerSocket = $row.Cores
        $spec.MemoryMB = $row.MemoryGB * 1024
        $policy = Get-SpbmStoragePolicy $row.StoragePolicy
        Set-SpbmEntityConfiguration -Entity $vm.ExtensionData.Config -Policy $policy
        $vm.ExtensionData.ReconfigVM($spec)
        Write-Host "Reconfigured $($vm.Name) with Cores: $($row.Cores), Memory: $($row.MemoryGB) GB, and Storage Policy: $($row.StoragePolicy)"
    }
    else {
        Write-Warning "VM $($row.VMName) not found"
    }
}

# Disconnect from vCenter Server
Disconnect-VIServer -Confirm:$false