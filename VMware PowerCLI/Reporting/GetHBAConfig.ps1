#Author: Rynardt Spies (Computacenter)
#Author Contact: rynardt.spies@computacenter.com
#Updated: February 2014
#Report on the HBA Link Speed, HBA Queue Depth, HBA Topology of each ESXi host.

#Connect to vCenter
$vcenter = "vcenter.domain"

#Cluster or datacenter names separated by comas.
$clusters = @("cluster01", ”cluster02”, ”Datacenter03”)
$ReportFile = "C:\Temp\HBAReport.csv"

$report = @()

connect-viserver $vcenter
foreach ($cluster in $clusters){
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
