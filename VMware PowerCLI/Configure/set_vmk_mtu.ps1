#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.00
#Description: Updates the MTU size for specified VMKERNEL virtual nics (vmk0, vmk1, vmk2, etc.)
#==============================================================================================

#Configure the following variables before running the script.
$vcenter = "vcenter.domain"
#Set the MTU size on the following vmk nics, separated by comas.
$vmks = @("vmk1")
#Desired MTU Size (1500=Standard, 9000=Jumbo-Frames)
$setMTUvalue = 1500

Write-Output "Connecting to vSphere Environment: $vcenter"
connect-viserver $vcenter
#Import hosts from a CSV file which contains the fields: HostName
$hosts = Import-csv "set_vmk_mtu-list.csv"

foreach ($importedHost in $hosts){
	$esxhost = Get-VMhost $importedHost.HostName
	foreach ($vmk in $vmks){
		#Set the MTU for each specified vmk to whatever is specified in $setMTUvalue
		$vmk = Get-VmHostNetworkAdapter -VMHost $esxhost -vmkernel | where{$_.Name -eq $vmk}
		$vmkmtu = $vmk.mtu
		Write-Output "The current MTU size for $vmk on $esxhost is $vmkmtu"
		Set-VMHostNetworkAdapter -VirtualNic $vmk -mtu $setMTUvalue -confirm:$false
		$vmk = Get-VMHostNetworkAdapter -VMHost $esxhost -vmkernel | where{$_.Name -eq $vmk}
		$vmkmtu = $vmk.mtu
		Write-Output "The MTU size for $vmk on $esxhost has now been set to $vmkmtu"
	}
}
Write-Output "Disconnecting from vSphere Environment: $vcenter"
disconnect-viserver $vcenter -confirm:$false