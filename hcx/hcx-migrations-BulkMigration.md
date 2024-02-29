# HCX Bulk Migration 

Bulk Migration is the most commonly used HCX migration type. This migration type allows customers to migrate workloads into Azure VMware Solution (AVS) in predefined batches or waves. Bulk Migrations can also be scheduled to cutover a predifined time or maintenance window of your choice.  

## Bulk Migration Process

The process of a Bulk migration is as follows, once the VM is selected for virtual machine HCX begins its initial replication of the data up to AVS. Once the initial replication has completed, HCX can migrate the VM into AVS or if the VM is scheduled to cutover at predefined maintence window, HCX will contine to replicate the changes periodically. 

## Bulk Migration Cutover

Once the VM is scheduled to migrate to AVS the cutover process begins. The HCX cutover process is as follows, First the source side VM will be powered off. Please note, the call to power off the VM on the source side is dependent on VMware tools, make sure your VMware tools is up to date or use the 'Force Power Off' option in HCX to power off the VM forcefully. 
After the VM has powered off, HCX performs one last final data sync. While the VM is powered off HCX can perform some optional maintance on your VM and upgrade the hardware version of the VM. Once the final data sync and optional VM maintenance is completed The VM will be powered on in the AVS environment. Upon the VM powering up in AVS, another optional maintenance can occur, the VM can have its vmtools upgraded. Finally the VM is up and running in AVS and ready for user validation. 

## Bulk Migration Advantages

One of the main advantages an HCX bulk migration is that after the migration to AVS, The on-prem VM remains in your source vCenter, HCX renames the VM with a POSIX timestamp. Incase of any issues with the replicated VM in AVS, the on-prem VM can be renamed and powered back on. This VM will be in the state it was before the power off process of HCX bulk migrations. No need to replicate back the VM in AVS to on-prem. 
Another advantage of Bulk migration is that it has the ability to migrate up to 200 VMs at a time per service mesh. This allows customer to migrate complete application and their depencies up into AVS in a single migration wave. 

## When to use Bulk Migration
Bulk migration is best suited for customers looking to move VMs up into AVS a large batches and quickly. This migration type does require a reboot of the VM, so minimal downtime for the VM should be expected and planned for. 
