$vcenter = "vcenter.spiesr.com"
$ReportFile = "c:\shelltimeout.csv"

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

