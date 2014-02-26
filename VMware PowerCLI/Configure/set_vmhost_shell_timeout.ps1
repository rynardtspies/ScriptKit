#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Set the ShellTimeOut Setting for all hosts in the specified cluster(s) and restarts
# the ESXiShell Service. Changes require the SSHShell TSM service to be restarted
#Tested with: VMware PowerCLI 5.5 Release 1.
#===================================================================================

#SETUP SCRIPT VARIABLES
#Specify the vCenter server by FQDN or IP Address
$vcenter = "vcenter.domain"
#List clusters by name, separate multiple clusters by comas.
$clusters = @("cluster01","cluster02")
#Confirm actions ($true or $false)
$confirmActions = $false
#If the shell service is running, should we restart the service to apply the change? ($true or $false)
$restartShellService = $true
#Change the Time out to the value specified here. (Default=1200, Disabled=0)
$shellTimeOutValue =  1200

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"#Try to connect to $vcenter. If not, fail gracefully with a message
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
	foreach ($esxhost in (Get-VMHost -Location $cluster)){
		$currentShellTimeOut = Get-AdvancedSetting -Entity $esxhost -Name UserVars.ESXiShellTimeOut
		$newShellTimeOut = $currentShellTimeOut | Set-AdvancedSetting -Value $shellTimeOutValue -confirm:$confirmActions
		Write-Output "$esxhost : Changed setting: $currentShellTimeOut to $newShellTimeOut"
		if ($restartShellService){
			$shellService = Get-VMHostService -VMHost $esxhost | where {$_.Key -eq "TSM"}
			#Check if the Shell Service is running and if it is, restart the service
			if($shellService.Running){
				Write-Output "Shell Service found running on $esxhost - Restarting service..."
				$shellService | Restart-VMHostService -confirm:$confirmActions
			}
			else {
				Write-Output "Shell Service not running. Aborting service restart..."
			}
		}
	}
}
Write-Output "Disconnecting from vSphere Environment $vcenter"
Disconnect-VIserver $vcenter -confirm:$confirmActions