#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.00
# Description:	Script to return all datastores seen in vCenter as well as their capacity,
# used space and free space.
#===========================================================================================

$vcenter = "vcenter.domain" # Enter the FQDN of the vCenter or ESX Server.
$ReportFile = "c:\TEMP\report_datastores_space.csv"

Write-Output "Connecting to vSphere Environment $vcenter"
Connect-VIServer $vcenter

#Let's define some functions to  call upon later in the script
function usedspace
{
    param($ds)
    [math]::Round(($ds.CapacityMB - $ds.FreeSpaceMB)/1024,2)
}
function dscapacity
{
    param($ds)
    [math]::Round($datastore.CapacityMB/1024,2)
}
function freespace
{
    param($ds)
    [math]::Round($datastore.FreeSpaceMB/1024,2)
}

#Functions have been defined.

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