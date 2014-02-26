#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Report on the ShellTimeOut Setting for all hosts in specified clusters/DC objects
#Tested with: VMware PowerCLI 5.5 Release 1.
#===================================================================================

$vcenter = "vcenter.domain"
#Specify cluster names separated by comas
$clusters = @("cluster01","cluster02")
$ReportFile = "c:\TEMP\report_ShellTimeOut-report.csv"

$report = @();
Clear Screen
write-Output "Connecting to vSphere environment: $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter"
	break
}
Write-Output "Successfully connected to: $ConnectionResult"

foreach ($cluster in $clusters){
	#Test if the current $cluster exists in the environment. If it doesn't continue to next $cluster
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Object $cluster could not be found"
		Continue
	}
	foreach ($esxhost in(Get-VMHost -Location $cluster)){
		Write-Output "Getting ESXi Shell timeout value for $esxhost"
		$ShellTimeOut = Get-VMHostAdvancedConfiguration -VMHost $esxhost -Name UserVars.ESXiShellTimeOut
		
		$row = ""|select HostName,ShellTimeOut
		$row.HostName = $esxhost.Name
		$row.ShellTimeOut = [string] $ShellTimeOut.Values
		$report += $row
	} 
}
Write-Output "Writing report to $ReportFile"
$report | export-csv $ReportFile -NoTypeInformation

Write-Output "Disconnecting from $vcenter"
Disconnect-VIserver $vcenter -confirm:$false

