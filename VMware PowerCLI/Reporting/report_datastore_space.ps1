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
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.01
# Description:	Script to return all datastores seen in vCenter as well as their capacity,
# used space and free space.
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#===========================================================================================

$vcenter = "vcenter.domain" # Enter the FQDN of the vCenter or ESX Server.
$ReportFile = "c:\TEMP\report_datastores_space.csv"

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"

#Let's define some functions to  call upon later in the script
function usedspace{
    param($ds)
    [math]::Round(($ds.CapacityMB - $ds.FreeSpaceMB)/1024,2)
}
function dscapacity{
    param($ds)
    [math]::Round($datastore.CapacityMB/1024,2)
}
function freespace{
    param($ds)
    [math]::Round($datastore.FreeSpaceMB/1024,2)
}

$datastores = Get-Datastore | sort Name
$Report = @()

ForEach ($datastore in $datastores){
        $row = "" | select-object Datastore, CapacityGB, UsedGB, FreeSpaceGB
        $row.Datastore = $datastore.Name
        $row.CapacityGB = dscapacity $datastore
        $row.UsedGB = usedspace $datastore
        $row.FreeSpaceGB = freespace $datastore
        $Report += $row
   }

Write-Output "Writing report to $ReportFile"
$Report | export-csv $ReportFile -NoTypeInformation

#Disconnect from the vSphere Host or Server
Write-Output "Disconnecting from vSphere Environment $vcenter"
Disconnect-VIServer $vCenter -confirm:$false