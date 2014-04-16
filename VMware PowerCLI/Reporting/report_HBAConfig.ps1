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
#Version: v1.00.01
#Updated: February 2014
#Report on the HBA Link Speed, HBA Queue Depth, HBA Topology of each ESXi host.
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#===================================================================================

#Specify vCenter Server Name or IP Address
$vcenter = "vcenter.domain"

#Cluster or datacenter names separated by comas.
$clusters = @("cluster01","cluster02","datacenter03")
$ReportFile = "C:\Temp\report_HBAConfig-report.csv"

$report = @()

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"

foreach ($cluster in $clusters){
	#Test if the current $cluster exists in the environment. If it doesn't continue to next $cluster
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Object $cluster could not be found"
	Continue
	}
	
    foreach ($esxhost in (get-VMHost -Location $cluster)){
        $esxcli = Get-ESXCLi -VMhost $esxhost
        $HBALinkSpeed = $esxcli.system.module.parameters.list("lpfc820") | where {$_.Name -eq "lpfc_link_speed"}
        $HBALUNQDepth = $esxcli.system.module.parameters.list("lpfc820") | where {$_.Name -eq "lpfc_lun_queue_depth"}
        $HBATopology = $esxcli.system.module.parameters.list("lpfc820") | where {$_.Name -eq "lpfc_topology"}
                
        $row = "" | select Hostname, Cluster, HBA_Link_Speed, HBA_LUN_Queue_Depth, HBA_Topology
        $row.HostName = $esxhost.Name
        $row.Cluster = $cluster
        $row.HBA_Link_Speed = $HBALinkSpeed.Value
        $row.HBA_LUN_Queue_Depth = $HBALUNQDepth.Value
        $row.HBA_Topology = $HBATopology.Value
        $report += $row
    }
}
Write-Output "Writing report to $ReportFile"
$report | export-csv $ReportFile -NoTypeInformation

Write-Output "Disconnecting from $vcenter"
Disconnect-VIServer $vcenter -confirm:$false
