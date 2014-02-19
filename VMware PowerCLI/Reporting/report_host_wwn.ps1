#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: February 2014
#Description: Report WWN Numbers

#Initialize variables
$vcenter = "vcenter.domain"
$clusters = @("cluster1","cluster2")
$ReportFile = "c:\report_host_wwn.csv"
$Report = @()

#Connect to vCenter Server
Write-Output "Connecting to vSphere Environment $vcenter"
Connect-VIServer $vcenter


foreach ($cluster in $clusters) {
    $vmhosts = $cluster | Get-vmhost
    if ($null -ne $vmhosts) {
        foreach ($vmhost in $vmhosts) {
            $vmhostview = $vmhost | Get-View
            foreach ($hba in $vmhostview.config.storagedevice.hostbusadapter) {
                if ($hba.PortWorldWideName) {
                    #Define Custom object
                    $row = "" | Select Clustername,Hostname,Hba,Wwpn
                    #Add properties to the newly created object
                    $row.ClusterName = $cluster.Name
                    $row.HostName = $vmhost.Name
                    $row.Hba = $hba.Device
                    $row.Wwpn = "{0:x}" -f $hba.PortWorldWideName
                    $Report += $row
                }
            }
        }
    }
}

$Report | export-csv $ReportFile -NoTypeInformation
Write-Output "Disconnecting from vSphere Environment $vcenter"
Disconnect-VIServer $vcenter -Confirm:$false