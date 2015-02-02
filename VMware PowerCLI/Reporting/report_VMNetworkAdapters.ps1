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
#
#===================================================================================
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2015
#Version: 1.00.00
#Description: Lists all network adapters, their type and connected network
#				for all VMs inventoried on a VI-Server
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2015 Rynardt Spies
#===========================================================================================

#Specify one or more vcenter servers (FQDN or IP), separated by comas
$vcenters = @("vcenter.domain","vcenter2.domain")
$reportfile = "C:\TEMP\report_vm_netowkradapters.csv"
$vCenterConnections = @()

Clear Screen
#Connect to all of the vcenter servers
foreach ($vcenter in $vcenters){
	write-Output "Connecting to vSphere environment: $vcenter"
	#Try to connect to $vcenter. If not, fail gracefully with a message
	if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
		Write-Output "Could not connect to $vcenter. Check server address."
		Continue
	}
	#Add the connected vCenter to the list of connections
	$vCenterConnections += $ConnectionResult
}
#See if any vCenter connections were made. If not, quit gracefully
if (($null=@()) -ne ($vCenterConnections)){
	Write-Output "Unable to connect to any of the specified vCenter Servers"
	break
	}
Write-Output "Successfully connected to the following servers:"
$vCenterConnections

#Initialise the report array
$report = @()
	
Write-Output "Gathering Virtual Machine Information from all connected vCenter servers..."
#Only get the name, Host, Folder and uid of each virtual machine and parse the values into $vmlist
$vmlist = Get-VM | sort $_.name
#Process each virtual machine within the $vmlist object
foreach ($vm in $vmlist){
	$netadapters = Get-NetworkAdapter -VM $vm
	$vmname = $vm.name
	foreach ($netadapter in $netadapters){
		Write-Output "Getting information for VM: $vmname"
		#Create the first line of the output CSV file that will serve as the column header
		$row = "" | select Name,NetworkName,NetworkAdapterName,NetworkAdapterType,MACAddress
		
		#Print the information for the current VM into a new row
		$row.Name = $vmname
		$row.NetworkName = $netadapter.NetworkName
		$row.NetworkAdapterName = $netadapter.Name
		$row.NetworkAdapterType = $netadapter.Type
		$row.MACAddress = $netadapter.MACAddress
		#Add the completed row to the report
		$Report += $row
	}
}
# Write the completed report to a CSV file as specified by $outFile
Write-Output "Writing report to $reportfile"
$Report | export-csv $reportfile -NoTypeInformation

#Disconnect from all vCenter Servers
foreach ($vcConnection in $vCenterConnections){
	Write-Output "Disconnecting from vSphere Environment $vcConnection"
	Disconnect-VIServer $vcConnection -confirm:$false
}