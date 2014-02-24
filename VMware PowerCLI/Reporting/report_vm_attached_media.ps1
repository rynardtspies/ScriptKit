

$vcenter = "vcenter.spiesr.com"$clusters = @("Cluster01")
$ReportFile = "C:\TEMP\report_vm_atached_media-report.csv"
$report = @()

Write-Output "Connecting to vSphere environment $vcenter"connect-viserver $vcenter

foreach ($cluster in $clusters){
	$vms = Get-VM
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

$report | export-csv $ReportFile -NoTypeInformation

Disconnect-VIServer $vcenter -confirm:$false
