#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v0.02.00
#Updated: February 2014
#Set the ShellTimeOut Setting for all hosts in the specified cluster(s)
#==================================================================================

#SETUP SCRIPT VARIABLES
#Specify the vCenter server by FQDN or IP Address
$vcenter = "vcenter"
#List clusters by name, separate multiple clusters by comas.
$clusters = @("cluster01","cluster02")
#Confirm actions ($true or $false)
$confirmActions = $false
#Change the Time out to the value specified here. (Default=1200, Disabled=0)
$shellTimeOutValue =  600

#Clear the console screen
Clear Screen
write-Output "Connecting to vSphere Environment $vcenter"Connect-VIServer $vcenter

foreach ($cluster in $clusters){
	foreach ($esxhost in (Get-VMHost -Location $cluster)){
		$currentShellTimeOut = Get-AdvancedSetting -Entity $esxhost -Name UserVars.ESXiShellTimeOut
		$newShellTimeOut = $currentShellTimeOut | Set-AdvancedSetting -Value $shellTimeOutValue -confirm:$confirmActions
		Write-Output "$esxhost : Changed setting: $currentShellTimeOut to $newShellTimeOut"
	}
}
Write-Output "Disconnecting from vSphere Environment $vcenter"
Disconnect-VIserver $vcenter -confirm:$confirmActions