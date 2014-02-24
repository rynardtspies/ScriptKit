#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.00
# Description:	Return all CD and Floppy Devices for each VM, including connection state
#===========================================================================================

#Enter vCenter Server Name or IP Address
$vcenter = "vcenter.domain"
#Specify a datacenter name, or cluster names, separated by comas$clusters = @("Cluster01","Cluster02")
#Specify there report file name and loccation
$ReportFile = "C:\TEMP\report_vm_atached_media-report.csv"
$report = @()

#Connect to the vcenter server
Write-Output "Connecting to vSphere environment $vcenter"connect-viserver $vcenter

#Cycle through each specified cluster or datacenter object in $clusters
foreach ($cluster in $clusters){
	$vms = Get-VM -Location $cluster
	foreach ($vm in $vms){
		$CDDrives = Get-CDDrive $vm
		$FloppyDrives = Get-FloppyDrive $vm
		foreach ($CDDrive in $CDDrives){
			$row = "" | Select Cluster, VMName, CDDriveName, CDISOPath, CDHostDevice, CDRemoteDevice, CDConnected, CDStartConnected, FloppyDriveName, FloppyImagePath, FloppyHostdevice, FloppyRemoteDevice, FloppyConnected, FloppyStartConnected
			$row.Cluster = $cluster
			$row.VMName = $vm
			$row.CDDriveName = $CDDrive.Name
			$row.CDISOPath = $CDDrive.ISOPath
			$row.CDHostDevice = $CDDrive.HostDevice
			$row.CDRemoteDevice = $CDDrive.RemoteDevice
			$row.CDConnected = $CDDrive.ConnectionState.Connected
			$row.CDStartConnected = $CDDrive.ConnectionState.StartConnected
			$report += $row
		}
		foreach ($FloppyDrive in $FloppyDrives){
			$row = "" | Select Cluster, VMName, CDDriveName, CDISOPath, CDHostDevice, CDRemoteDevice, CDConnected, CDStartConnected, FloppyDriveName, FloppyImagePath, FloppyHostdevice, FloppyRemoteDevice, FloppyConnected, FloppyStartConnected
			$row.Cluster = $cluster
			$row.VMName = $vm
			$row.FloppyDriveName = $FloppyDrive.Name
			$row.FloppyImagePath = $FloppyDrive.FloppyImagePath
			$row.FloppyHostDevice = $FloppyDrive.HostDevice
			$row.FloppyRemoteDevice = $FloppyDrive.RemoteDevice
			$row.FloppyConnected = $FloppyDrive.ConnectionState.Connected
			$row.FloppyStartConnected = $FloppyDrive.ConnectionState.StartConnected
			$report += $row
		}
	}
}
Write-Output "Writing the report to $ReportFile"
$report | export-csv $ReportFile -NoTypeInformation

Write-Output "Disconnecting from $vcenter"
Disconnect-VIServer $vcenter -confirm:$false
