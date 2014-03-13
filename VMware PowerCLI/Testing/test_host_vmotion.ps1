#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: March 2014
#Test vMotion on all hosts in specified cluster by migrating a test VM between hosts at
# a set interval
#Tested with: VMware PowerCLI 5.5 Release 1.
#===================================================================================

#Specify the vCenter server to connect to
$vcenter = "vcenter"
#Specify the name of a VM to use as a test VM
$testvm = "TestVM"
#Specify the cluster name to test
$cluster = "ClusterName"
#Enter the interval in seconds between migrations
$interval = 60
#Enter the number of packets to ping the testvm with
$pingtestpacketcount = 10
#Specify the resport file path and filename 
$reportfile = "C:\Temp\test_host_vmotion-report.csv"

Clear Screen
#Connect to vcenter server
if(!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	#Connection could not be established to $vcenter
	Write-Output "Could not connect to $vcenter."
	break
}
#If the script got this far, then we should be connected
Write-Output "Connected to $ConnectionResult"
$report = @()

if (!($actCluster = Get-Cluster $cluster -ErrorAction SilentlyContinue)){
	Write-Output "The object $cluster was not found on $ConnectionResult. Exiting..."
	Disconnect-VIServer $ConnectionResult -confirm:$false
		Write-Output "Disconnected from $ConnectionResult"
	break
}
Write-Output "Found Cluster: $actCluster on $ConnectionResult"

$esxhosts = Get-VMhost -Location $actCluster | sort $_.Name
if ($null -eq $esxhosts) {
	Write-Output "No hosts found in cluster $actCluster"
	Disconnect-VIServer $ConnectionResult -confirm:$false
	Write-Output "Disconnected from $ConnectionResult"
	break
}

#Confirm that the testvm exists
if (!($migVM = Get-VM $testvm -ErrorAction SilentlyContinue)){
	Write-Output "The VM $testvm was not found! Exiting..."
	Disconnect-VIServer $ConnectionResult -confirm:$false
	Write-Output "Disconnected from $ConnectionResult"
	break
}
$TestVMIP = $migVM.ExtensionData.Summary.Guest.IpAddress
Write-Output "All network connectivity testing to $migVM will be carried out using IP $TestVMIP"

#Ensure that the test VM is on the first host in the cluster, if not migrate it to the host
if (!($migVM.VMHost -eq  $esxhosts[0])){
	Write-Output "Moving $migVM to first host in cluster $cluster"
	Move-VM $migVM -Destination $esxhosts[0] | select Name,PowerState,VMHost
	Write-Output "Testing network connectivity to $migVM on $TestVMIP..."
	if ($PingResult = Test-Connection $TestVMIP -Count $pingtestpacketcount -Quiet){
		Write-Output "Network connectivity test to $migVM successful. "
	} else {
		write-output "Network connectivity test to $migVM failed..."
	}
	$row = "" | select VMName, VMHostName, TestedIP, PingTestPass
	$row.VMName = $migVM.Name
	$row.VMHostName = $migVM.VMHost
	$row.TestedIP = $TestVMIP
	$row.PingTestPass = $PingResult
	$report += $row
}
	
for ($i = 1; $i -le ($esxhosts.count -1); $i++){
	#Refresh $migVM details to current residing host
	$migVM = Get-VM $testvm
	$nextVMHost = $esxhosts[$i]
	Write-Output "Waiting $interval seconds before next migration..."
	Start-Sleep -s $interval
	Write-Output "Migrating $migVM to $nextVMHost..."
	Move-VM $migVM -Destination $nextVMHost |select Name,PowerState,VMHost
	Write-Output "Testing network connectivity to $migVM on $TestVMIP..."
	if ($PingResult = Test-Connection $TestVMIP -Count $pingtestpacketcount -Quiet){
		Write-Output "Network connectivity test to $migVM successful. "
	} else {
		write-output "Network connectivity test to $migVM failed..."
	}
	$row = "" | select VMName, VMHostName, TestedIP, PingTestPass
	$row.VMName = $migVM.Name
	$row.VMHostName = $migVM.VMHost
	$row.TestedIP = $TestVMIP
	$row.PingTestPass = $PingResult
	$report += $row
}

Write-Output "Writing results report to $reportfile"
$report | export-csv $reportfile -NoTypeInformation

Write-Output "Disconnecting form $ConnectionResult"
Disconnect-VIServer $ConnectionResult -confirm:$false
Write-Output "Disconnected from $ConnectionResult"