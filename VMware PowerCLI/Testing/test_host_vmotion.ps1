#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
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
$interval = 30

Clear Screen
#Connect to vcenter server
if(!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	#Connection could not be established to $vcenter
	Write-Output "Could not connect to $vcenter."
	break
}
#If the script got this far, then we should be connected
Write-Output "Connected to $ConnectionResult"

if (!($actCluster = Get-Cluster $cluster -ErrorAction SilentlyContinue)){
	Write-Output "The object $cluster was not found on $ConnectionResult. Exiting..."
	Disconnect-VIServer $ConnectionResult -confirm:$false
		Write-Output "Disconnected from $ConnectionResult"
	break
}
Write-Output "Found Cluster: $actCluster on $ConnectionResult"

$esxhosts = Get-VMhost -Location $actCluster
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

#Ensure that the test VM is on the first host in the cluster, if not migrate it to the host
if (!($migVM.VMHost -eq  $esxhosts[0].Name)){
	Write-Output "Moving $migVM to first host in cluster $cluster"
	Move-VM $testvm -Destination $esxhosts[0]
}
for ($i = 1; $i -le ($esxhosts.count -1); $i++){
	$nextVMHost = $esxhosts[$i]
	Write-Output "Waiting $interval seconds before next migration..."
	Start-Sleep -s $interval
	Write-Output "Migrating $migVM to $nextVMHost..."
	Move-VM $migVm -Destination $nextVMHost
}

Write-Output "Disconnecting form $ConnectionResult"
Disconnect-VIServer $ConnectionResult -confirm:$false
Write-Output "Disconnected from $ConnectionResult"