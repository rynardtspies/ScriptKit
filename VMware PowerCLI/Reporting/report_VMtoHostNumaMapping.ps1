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
#=================================================================================================
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: September 2014
#Version: 1.00.00
#Description: Reports on the vCPU and memory configuration of all VMs managed by connected vCenter.
# The report also provides CPu and memory architecture information of the hosts that the VM is 
# running on.
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#===================================================================================================

#Specify one or more vcenter servers (FQDN or IP), separated by comas
$vcenters = @("vcenter1", "vcenter2")
$reportfile = "C:\TEMP\report_VMtoHostNumaMapping.csv"
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
if ($vCenterConnections.Count -eq 0 ){
	Write-Output "Unable to connect to any of the specified vCenter Servers"
	break
	}
Write-Output "Successfully connected to the following servers:"
$vCenterConnections

#Initialise the report array
$report = @()
$i = 0
Write-Output "Getting virtual machine configuration information. This could take some time..."
$vms = Get-VM | Get-View
Write-Output "Getting ESX Host configuration information. This could take some time..."
$hostsview = Get-VmHost | Get-View
$vmcount = $vms.count
foreach ($vm in $vms){
	$i++
	Write-Progress -activity "Processing..." -status "Reporting on VM $i of $vmcount VMs" -PercentComplete (($i / $vmcount)*100)
	$hostview = $hostsview | where {$_.Summary.Host -eq $vm.Runtime.Host}
	$row = "" | select VM, NumCPU, CPUCoresPerSocket, MemoryMB, Host, HostCPUSockets, HostCPUCores, HostCPUCoresPerSocket, HostCPUThreads, HostNumaNodes,HostMemoryMB
	$row.VM = $vm.Name
	$row.NumCPU = $vm.Config.Hardware.NumCPU
	$row.CPUCoresPerSocket = $vm.Config.Hardware.NumCoresPerSocket
	$row.MemoryMB = $vm.Config.Hardware.MemoryMB
	$row.Host = $hostview.Name
	$row.HostCPUSockets = $hostview.Hardware.CpuInfo.NumCPUPackages
	$row.HostCPUCores = $hostview.Hardware.CpuInfo.NumCPUCores
	$row.HostCPUCoresPerSocket = $hostview.Hardware.CpuInfo.NumCPUCores / $hostview.Hardware.CpuInfo.NumCPUPackages
	$row.HostCPUThreads = $hostview.Hardware.CpuInfo.NumCpuThreads
	$row.HostNumaNodes = $hostview.Hardware.NumaInfo.NumNodes
	$row.HostMemoryMB = (($hostview.Hardware.MemorySize /1024) / 1024)
	
	$report += $row;
}
	
# Write the completed report to a CSV file as specified by $outFile
Write-Output "Writing report to $reportfile"
$Report | export-csv $reportfile -NoTypeInformation

#Disconnect from all vCenter Servers
foreach ($vcConnection in $vCenterConnections){
	Write-Output "Disconnecting from vSphere Environment $vcConnection"
	Disconnect-VIServer $vcConnection -confirm:$false
}
	

