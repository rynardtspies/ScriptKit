#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.00
#Description: Creates up to two vMotion interfaces and configures them with details specified in a CSV
#				file. For a single interface, comment out the entire vmk2 section.
#==============================================================================================

#Configure the following variables before running the script.
$vcenter = "vcenter.domain"
#Desired vmk NIC MTU Size (1500=Standard, 9000=Jumbo-Frames)
$setMTUvalue = 1500

Write-Output "Connecting to vSphere Environment: $vcenter"
connect-viserver $vcenter

#Import hosts from a CSV file which contains the fields: Hostname,vmotion1IP,vmotion1sm,vmotion1vs,vmotion1pg,vmotion2IP,vmotion2sm,vmotion2vs,vmotion2pg
$hosts = Import-csv "create_vmotion_vmk-list.csv"

foreach ($Host in $hosts){
	$esxhost = Get-VMhost $Host.HostName
	
	###VMK1 SECTION###
	#Get the vSwitch where vmk1 will be added to 
	$myVirtualSwitch = Get-VirtualSwitch -VMHost $esxhost -Name $Host.vmotion1vs
	#Add vmk1
	New-VMHostNetworkAdapter -VMHost $esxhost -Portgroup $Host.vmotion1pg -VirtualSwitch $myVirtualSwitch -IP $Host.vmotion1IP -SubnetMask $Host.vmotion1sm -mtu $setMTUvalue -ManagementTrafficEnabled:$false -FaultToleranceLoggingEnabled:$false -VMotionEnabled:$true
	
	###VMK2 SECTION###	
	#Get the vSwitch where vmk2 will be added to 
	$myVirtualSwitch = Get-VirtualSwitch -VMHost $esxhost -Name $Host.vmotion2vs
	#Add vmk2
	New-VMHostNetworkAdapter -VMHost $esxhost -Portgroup $Host.vmotion2pg -VirtualSwitch $myVirtualSwitch -IP $Host.vmotion2IP -SubnetMask $Host.vmotion2sm -mtu $setMTUvalue -ManagementTrafficEnabled:$false -FaultToleranceLoggingEnabled:$false -VMotionEnabled:$true
}
Write-Output "Disconnecting from vSphere Environment: $vcenter"
disconnect-viserver $vcenter -confirm:$false