#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Report on the Management and vMotion IP Addresses (vmk)
#Tested with: VMware PowerCLI 5.5 Release 1.
#===================================================================================

#Specify the vCenter server name or IP Address
$vcenter = "vcenter.domain"
#Specify datacenter or cluster names to report on, separated by comas.
$clusters = @("Cluster01","Cluster02")
$reportfile = "c:\TEMP\report_MgmtvMotionIPs_report.csv"

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"

$report = @()
foreach ($cluster in $clusters){
	#Test if the current $cluster exists in the environment. If it doesn't continue to next $cluster
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Object $cluster could not be found"
		Continue
	}
	foreach ($esxHost in (Get-VMhost -Location $cluster | sort $_.Name)){
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
Write-Output "Writing report to $reportfile"
$report | export-csv $reportfile -NoTypeInformation
Write-Output "Disconnecting from $vcenter"
Disconnect-VIServer $vcenter -confirm:$false