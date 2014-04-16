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
#Version: v1.00.01
#Updated: March 2014
#Report on the virtual machine snapshots created for each virtual machine in the specified cluster
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#===================================================================================

$vcenter = "vcenter.domain"
#Specify cluster names separated by comas
$clusters = @("cluster01","cluster02")
$reportfile = "C:\Temp\report_snapshots-report.csv"

if(!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	#failed to establish a connection to $vcenter
	Write-Output "Failed to connect to $vcenter. Exiting..."
	Break
}
Write-Output "Connected to $ConnectionResult"
$report = @()
foreach ($cluster in $clusters){
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Object $cluster could not be found."
		Continue
	}
	$vms = Get-VM -Location $cluster
	foreach ($vm in $vms){
		$snapshots = Get-Snapshot -VM $vm
		if(!($null -eq $snapshots)){
			Write-Output "Found snapshots for $vm"
			foreach ($snapshot in $snapshots) {
				$row = "" | select VMName, Cluster, SnapshotName, Created, PowerState, SizeMB, ParentSnapshot, IsCurrent
				$row.VMName = $vm.Name
				$row.Cluster = $cluster
				$row.SnapshotName = $snapshot.Name
				$row.Created = $snapshot.Created
				$row.PowerState = $snapshot.PowerState
				$row.SizeMB = $snapshot.SizeMB
				$row.ParentSnapshot = $snapshot.ParentSnapshot
				$row.IsCurrent = $snapshot.IsCurrent
				$report += $row
			}
		}
	}
}
Write-Output "Writing Report to $reportfile"
$report | Export-CSV $reportfile -NoTypeInformation

Write-Output "Disconnecting from $ConnectionResult"
Disconnect-VIServer $ConnectionResult -confirm:$false