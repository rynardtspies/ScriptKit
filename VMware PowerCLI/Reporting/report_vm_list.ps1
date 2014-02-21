#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Updated: February 2014
#Version: 1.00.00
#Description: Reports the Name, vCenter, Datacenter, Cluster, Host and Folder for every virtual
#				machine visible within the PowerCLI session. Also works when connected to multiple VI servers.
#				Output is saved to a CSV file as specified in $ReportFile
#				Helpful in large environments with many vCenter servers.
#===========================================================================================

#Specify vcenter servers, separated by comas
$vcenters = @("vcenter.spiesr.com")
$ReportFile = "C:\TEMP\report_vm_list.csv"

#Connect to all of the vcenter servers
foreach ($vcenter in $vcenters){
	Write-Output "Connecting to vSphere Environment $vcenter"
	connect-viserver $vcenter
	}

#Only get the name, Host, Folder and uid of each virtual machine and parse the values into $vmlist
$vmlist = get-vm | select Name, VMHost, Folder, uid, ExtensionData

#Initialise the report array
$report = @()

#Process each virtual machine within the $vmlist object
foreach ($vm in $vmlist) {
	#Locate the datacenter where the current VM is located, and only return the name property
	$dc = Get-datacenter -VM $vm.Name | select name
	$datastore = Get-Datastore | where {$_.id -eq $vm.ExtensionData.Datastore} | select Name
	
	#Locate the cluster where the current VM is located and only return the name property
    $cluster = Get-Cluster -VM $vm.Name | select name
	
	#Create the first line of the output CSV file that will serve as the column header
	$row = "" | select Name,vCenter,Datacenter,Cluster,Host,Datastore,Folder
	
	#Print the information for the current VM into a new row
	$row.Name = $vm.name
	$row.vCenter = $vm.uid.tostring().split(":")[0].split("@")[1]
    $row.Datacenter = $dc.name
    $row.Cluster = $cluster.name
	$row.Host = $vm.VMHost
	$row.Datastore = $datastore.Name
    $row.Folder = $vm.folder
	
	#Add the completed row to the report
	$Report += $row
}
# Write the completed report to a CSV file as specified by $outFile
$Report | export-csv $ReportFile -NoTypeInformation

#Disconnect from all vCenter Servers
foreach ($vcenter in $vcenters){
Write-Output "Disconnecting from vSphere Environment $vcenter"
Disconnect-VIServer $vcenter -confirm:$false
}