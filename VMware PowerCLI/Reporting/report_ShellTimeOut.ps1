#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: February 2014
#Report on the ShellTimeOut Setting for all hosts.

$vcenter = "vcenter.domain"
$ReportFile = "c:\report_shelltimeout.csv"

$report = @();

connect-viserver $vcenter
foreach ($esxhost in(Get-VMHost)){
	$ShellTimeOut = Get-VMHostAdvancedConfiguration -VMHost $esxhost -Name UserVars.ESXiShellTimeOut
	
	$row = ""|select HostName,ShellTimeOut
	$row.HostName = $esxhost.Name
	$row.ShellTimeOut = [string] $ShellTimeOut.Values
	$report += $row
} 

$report | export-csv $ReportFile -NoTypeInformation

disconnect-viserver $vcenter -confirm:$false

