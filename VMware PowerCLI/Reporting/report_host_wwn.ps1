#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Description: Report WWN Numbers for hosts specified in $clusters
#Tested with: VMware PowerCLI 5.5 Release 1.
#====================================================================================

#Specify vCenter Server Name or IP address
$vcenter = "vcenter.domain"
#Specify the datacenters or cluster objects to include hosts from, separated by comas
$clusters = @("cluster01","cluster02")
#Specify the file to write the report to
$ReportFile = "c:\TEMP\report_host_wwn.csv"
$Report = @()

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"

foreach ($cluster in $clusters) {
	#Test if the current $cluster exists in the environment. If it doesn't continue to next $cluster
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Object $cluster could not be found"
		Continue
	}
    if ($null -ne ($vmhosts = Get-VMHost -Location $cluster)) {
        foreach ($vmhost in $vmhosts) {
			Write-Output "Getting HBA Information for $vmhost"
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

Write-Output "Writing report to $ReportFile"
$Report | export-csv $ReportFile -NoTypeInformation

Write-Output "Disconnecting from vSphere Environment $vcenter"
Disconnect-VIServer $vcenter -Confirm:$false