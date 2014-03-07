#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: March 2014
#Report on the Management and vMotion IP Addresses (vmk)
#Tested with: VMware PowerCLI 5.5 Release 1.
#NOTE: This script will replace report_MgmtvMotionIPs.ps1 in the next release of
# ScriptKit (V1.00.02)
#===================================================================================

#Specify the vCenter server name or IP Address
$vcenter = "vcenter"
#Specify datacenter or cluster names to report on, separated by commas.
$clusters = @("cluster01", "cluster02")
$reportfile = "C:\Temp\report_host_vmknics-report.csv"

#Clear the console screen
Clear Screen
Write-Output "Attempting to open a connection to: $vcenter"
#Try to connect to $vcenter
if(!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	#Connection attempt has failed
	Write-Output "Unable to connect to $vcenter. Exiting..."
	Break
}
Write-Output "Connected to $ConnectionResult"
$report = @()
foreach ($cluster in $clusters){
	if(!($currentcluster = Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Object $cluster could not be found."
		#Now continue to the next $cluster in $clusters
		Continue
	}
	$esxhosts = Get-VMhost -Location $cluster
	if (!($null -ne $esxhosts)){
		Write-Output "No Hosts Found in $cluster"
		Continue
		}
	foreach ($esxhost in $esxhosts){
		Write-Output "Retrieving VMKernel Network Adapter Information for $esxhost"
		$vmkadapters = Get-VMHostNetworkAdapter $esxhost -VMKernel
		foreach ($vmkadapter in $vmkadapters) {
			$row = "" | select Hostname, Cluster, AdapterName, Portgroup, MAC, IPAddress, SubnetMask, MTU, DHCPEnabled, ManagementTrafficEnabled, VMotionEnabled, FTLogginEnabled, VsanTrafficEnabled
			$row.Hostname = $vmkadapter.VMhost.Name
			$row.Cluster = $currentcluster.Name
			$row.Adaptername = $vmkadapter.Name
			$row.Portgroup = $vmkadapter.PortGroupName
			$row.MAC = $vmkadapter.Mac
			$row.IPAddress = $vmkadapter.IP
			$row.SubnetMask = $vmkadapter.SubnetMask
			$row.MTU = $vmkadapter.Mtu
			$row.DHCPEnabled = $vmkadapter.DHCPEnabled
			$row.ManagementTrafficEnabled = $vmkadapter.ManagementTrafficEnabled
			$row.VMotionEnabled = $vmkadapter.VMotionEnabled
			$row.FTLogginEnabled = $vmkadapter.FaultToleranceLoggingEnabled
			$row.VsanTrafficEnabled = $vmkadapter.VsanTrafficEnabled
			$report += $row
		}
	}
}

#Write report
Write-Output "Writing report to $reportfile"
$report | export-csv $reportfile -NoTypeInformation

#Disconnect from the $vcenter server via $ConnecitonResult
Write-Output "Disconnecting from $ConnectionResult"
Disconnect-VIServer $ConnectionResult -confirm:$false