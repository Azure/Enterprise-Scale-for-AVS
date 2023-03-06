# Automating vCenter using Scripts

This section will show some examples on how to manipulate vCenter objects through automation scripts using VMware PowerCLI or some other feasible scripting tools.

## Example: Modify existing VMs CPU/Memory allocation and update Storage Policy

This example uses VMware PowerCLI script that reads a CSV file with four columns ("VMName", "Cores", "MemoryGB", and "StoragePolicy") and reconfigures the matching VMs in vCenter with the new CPU, Memory, and Storage Policy settings:

See example here: [Link](/BrownField/Scripts/Reconfigure-VMs.ps1)

**Instructions**:

1. Save the script as a PowerShell file (e.g. "Reconfigure-VMs.ps1").
2. Create a CSV file (e.g. "VM_Config.csv") with four columns: "VMName", "Cores", "MemoryGB", and "StoragePolicy", and populate it with the names of the VMs and the new CPU cores count, memory allocation, and storage policy settings to apply.
3. Open a PowerShell console and navigate to the directory where you saved the script and the CSV file.
4. Run the script by typing its name (e.g. "Reconfigure-VMs.ps1") and pressing Enter.
5. The script will connect to the vCenter Server, read the CSV file, and reconfigure the matching VMs in vCenter with the new CPU, memory, and storage policy settings. The script will display a message for each VM that was successfully reconfigured, and a warning message for each VM that was not found.
6. When the script is done, it will disconnect from the vCenter Server.
