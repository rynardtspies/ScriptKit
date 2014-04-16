# This file is part of ScriptKit.
#
#    ScriptKit is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    ScriptKit is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with ScriptKit.  If not, see <http://www.gnu.org/licenses/>
#==============================================================================================
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: v1.00.01
#Description: Creates up to two vMotion interfaces and configures them with details specified in a CSV
#				file. For a single interface, comment out the entire vmk2 section.
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#==============================================================================================



#Configure the following variables before running the script.
$vcenter = "vcenter.domain"
#Desired vmk NIC MTU Size (1500=Standard, 9000=Jumbo-Frames)
$setMTUvalue = 1500

Clear Screen
write-Output "Connecting to vSphere environment: $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter"
	break
}
Write-Output "Successfully connected to: $ConnectionResult"

#Import hosts from a CSV file which contains the fields: Hostname,vmotion1IP,vmotion1sm,vmotion1vs,vmotion1pg,vmotion2IP,vmotion2sm,vmotion2vs,vmotion2pg
$hosts = Import-csv "create_vmotion_vmk-list.csv"

foreach ($iHost in $hosts){
	$esxhost = Get-VMhost $iHost.HostName
	
	###VMK1 SECTION###
	#Get the vSwitch where vmk1 will be added to 
	$myVirtualSwitch = Get-VirtualSwitch -VMHost $esxhost -Name $iHost.vmotion1vs
	#Add vmk1
	New-VMHostNetworkAdapter -VMHost $esxhost -Portgroup $iHost.vmotion1pg -VirtualSwitch $myVirtualSwitch -IP $iHost.vmotion1IP -SubnetMask $iHost.vmotion1sm -mtu $setMTUvalue -ManagementTrafficEnabled:$false -FaultToleranceLoggingEnabled:$false -VMotionEnabled:$true
	
	###VMK2 SECTION###	
	#Get the vSwitch where vmk2 will be added to 
	$myVirtualSwitch = Get-VirtualSwitch -VMHost $esxhost -Name $iHost.vmotion2vs
	#Add vmk2
	New-VMHostNetworkAdapter -VMHost $esxhost -Portgroup $iHost.vmotion2pg -VirtualSwitch $myVirtualSwitch -IP $iHost.vmotion2IP -SubnetMask $iHost.vmotion2sm -mtu $setMTUvalue -ManagementTrafficEnabled:$false -FaultToleranceLoggingEnabled:$false -VMotionEnabled:$true
}
Write-Output "Disconnecting from vSphere Environment: $vcenter"
disconnect-viserver $vcenter -confirm:$false