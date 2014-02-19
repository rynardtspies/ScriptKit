#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: February 2014
#Report on the Management and vMotion IP Addresses (vmk)


$vcenter = "vcenter.domain"
$clusters = @("Cluster01")
$reportfile = "c:\report_MgmtvMotionIPs_report.csv"

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
$report | export-csv $reportfile -NoTypeInformation
Disconnect-VIServer $vcenter -confirm:$false