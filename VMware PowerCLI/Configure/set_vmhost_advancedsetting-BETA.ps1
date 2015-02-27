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
#
#===================================================================================
#Scriptname: set_vmhost_advacedsetting-BETA.ps1
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v0.01
#Updated: February 2015
#Set advacned host setting on all hosts in specified clusters
#Tested with: VMware PowerCLI 5.5 Release 2. THIS IS A BETA SCRIPT.

#NOTE: This script needs to be updated to better display dvSwitch components
#Copyright (c) 2010 - 2015 Rynardt Spies
#===================================================================================

#Specify some variable values first
$vcenter = "vcenter_servername"
$clusters = @("Cluster01", "Cluster02")
$reportdate = Get-Date -Format "dd-MM-yyyy"
$starttime = (Get-Date -f "HH:MM")
$settingname = "VMKernel.Boot.terminateVMOnPDL"
$settovalue = $false #Set to $true or $false for boolean
#Specify the report file WITHOUT .csv file extension. This will be added later by the script
$reportfile = "C:\TEMP\set_vmhost_advancedsetting"

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"
Write-Output "The system time is now $starttime on $reportdate"

$report = @()

foreach ($cluster in $clusters){
	$myVMhosts = Get-VMHost -Location $cluster
	foreach ($myVMHost in $myVMHosts){
		$row = "" | select Hostname, Settingname, OldValue, NewValue
		$advsetting = Get-AdvancedSetting -Entity $myVMHost | where {$_.Name -eq $settingname}
		if ($advsetting.Name -ne $settingname){
			Write-Output "Could not verify that the correct setting was returned for $settingname"
			$row.Hostname = $myVMHost.Name
			$row.Settingname = $settingname
			$row.OldValue = "Setting Not Found"
			$row.NewValue = "Setting Not Found"
			$report += $row
			continue;
		}
		
		$StgOldVal = $advsetting.Value
		$StgNewVal = Set-AdvancedSetting $advsetting -Value $settovalue -confirm:$false | select Value
		
		$row.Hostname = $myVMHost.Name
		$row.Settingname = $settingname
		$row.OldValue = $StgOldVal.ToString()
		$row.NewValue = $StgNewVal.Value.ToString()
		$report += $row
	}

	$endDate = Get-Date -Format "dd-MM-yyyy"
}
	$endTime = (Get-Date -f "HH-MM")

	$reportfile = $reportfile+"-"+$endDate+"-"+$endTime+".csv"
	Write-Output "Writing Report Information to '$reportfile' "
	$report | export-csv $reportfile -NoTypeInformation

	Write-Output "Disconnecting from Server: '$vcenter'..."
	Disconnect-VIServer $vcenter -confirm:$false	


