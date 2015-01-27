# This file is part of ScriptKit.
#
#    ScriptKit is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    ScriptKit is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with ScriptKit.  If not, see <http://www.gnu.org/licenses/>
#==============================================================================================
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: 27 January 2015
#Version: v0.00.01 <- CAUTION: NOTE EARLY RELEASE!!!
#===============
#PRE-REQUISITES:
#===============
#	1. Microsoft ServerManager PowersShell Module
#	2. Microsoft Active Directory PowerShell Module
#	3. Run-As a user with sufficient privileges to:
#		a. Remove objects from Active Directory
#		b. Join new computers to an Active Directory Domain
#		c. Delete VMs from vCenter
#		d. Clone existing VMs in vCenter
#############################################
#Description: Refreshes a cloned VM from the source VM by completing:
#	1. Powers down the cloned VM
#	2. Deletes the cloned VM
#	3. If Windows, deletes the VMs Computer Object from Active Directory
#	4. Cloning an existing VM and using a pre-configured customization specification
#	5. Starts the new clone
#
#############################################
#Usage Instructions
#############################################
#1. Create a customization specification in vSphere with IP configuration set to DHCP OR to a static IP address
# if the resulting clone is required to always have the same IP address
#2. Assign values to the $variables below. Complete: vCenter server name, VM name to be cloned, resulting VM name, Customization Specification Name
#3. Ensure hat the script is exectued on a Windows Server with the Active Directory module for Powershell windows feature enabled
#4. Set the Windows server's PowerShell script execution policy to allow execution of scripts, as per: https://technet.microsoft.com/en-us/library/hh849812.aspx
#5. Create a Windows shortcut or scheduled task to execute the script in the format of: %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -File C:\PSScripts\refresh_vm_clone.ps1
#6. Execute the script with a user account with sufficient permissions. Refer to the pre-requisites section above.
#############################################
#DISCLAIMER
#############################################
#This script deletes items from vCenter and Active Directory. Use at own risk
#The author excepts no responsibility for any loss or damage resulting from direct
#or indirect use of this script 
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2015 Rynardt Spies
#==============================================================================================

#Configure the following variables before running the script.
$vcenter = "vcenter.domain"
#Enter the VM name that should be cloned from
$sourceVMName = "MyProdVM"


#!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!
#THIS IS VERY IMPORTANT!!!
#IF THE VM NAMED IN THE $newVMName VARIABLE BELOW ALREADY EXISTS, IT WILL BE POWERED OFF,
#DELETED FROM DISK AND IT'S COMPUTER OBJECT REMOVED FROM ACTIVE DIRECTORY AS PART OF THIS SCRIPT!!!
#ENSURE THAT YOU COMPLETE THE $VARIABLE BELOW CORRECTLY! THIS IS IRREVERSIBLE!
#YOU HAVE BEEN WARNED!!!
####################################
#Enter a name for the new resulting VM. ENSURE YOU GET THIS RIGHT!
$newVMName = "MyDevVM"

#Enter the name of the Guest OS Customization Specification already created in vSphere that should be used to customize this clone
$customspec = "MyDevVMSpec"

#Loading required PowerShell modules and span-ins
Import-Module ActiveDirectory
Import-Module ServerManager
Add-PSSnapin VMware.VimAutomation.Core

Clear Screen
write-Output "Connecting to vSphere environment: $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter"
	break
}
Write-Output "Successfully connected to: $ConnectionResult"

$RSATADPSFeature = Get-WindowsFeature RSAT-AD-PowerShell

if (!$RSATADPSFeature.Installed){
	Write-Output "Please install and enable the Active Directory PowersShell Module in Windows Features!"
	break;
}

Write-Output "Powering off $newVMName"
Stop-VM $newVMName -Confirm:$false

Write-Output "Deleting $newVMName from Disk!!!"
Remove-VM $newVMName -DeleteFromDisk -Confirm:$false

Write-Output "Removing the $newVMName computer object from Active Directory"
Remove-ADComputer $newVMName -Confirm:$false

Write-Output "Cloning $sourceVMName to $newVMName using Customization Specification $customspec"
$srcVM = Get-VM $sourceVMName
$newVM = New-VM -Name $newVMName -VMHost $srcVM.VMHost -VM $srcVM -OSCustomizationSpec $customspec

Write-Output "Starting new virtual machine..."
Start-VM $newVM

Write-Output "Disconnecting from vSphere Environment: $vcenter"
disconnect-viserver $vcenter -confirm:$false