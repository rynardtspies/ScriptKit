$vcenter = "vcenter.spiesr.com"
$clusters = @("Cluster01")

connect-viserver $vcenter

$report = @()
foreach ($cluster in $clusters){

	foreach ($esxHost in (Get-VMhost -Location $cluster | where {$_.ConnectionState -eq "Connected"} | sort $_.Name)){
		$NetInfo = Get-VMHostNetworkAdapter -VMhost $esxHost
		 foreach ($adapter in $Netinfo){
		$row = "" | select ClusterName, HostName, AdapterName, IP, SubnetMask, Mac, PortGroupName, vMotionEnabled
		$row.ClusterName = $cluster
		$row.HostName = $esxHost.Name
		$row.AdapterName = $adapter.Name
		$row.IP = $adapter.IP
		$row.SubnetMask = $adapter.SubnetMask
		$row.Mac = $adapter.Mac
		$row.PortGroupName = $adapter.PortGroupName
		$row.vMotionEnabled = $adapter.vMotionEnabled
		$report += $row
		}
		
	}
}
$report | export-csv "c:\report.csv" -NoTypeInformation
Disconnect-VIServer $vcenter -confirm:$false