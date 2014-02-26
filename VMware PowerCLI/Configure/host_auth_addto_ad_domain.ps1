#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Description: Add hosts in cluster to a specified AD Domain.
#Tested with: VMware PowerCLI 5.5 Release 1.
#===================================================================================

#vCenter server to connect to
$vcenter = "vcenter.domain"
#Clusters or DCs which hosts should be added to domain
$clusters = @("Cluster01","Cluster02")
$domainname = "domain.local"
#Specify an AD user
$authUser = "DOMAIN\User"
#Specify the AD User password in literal quotes to account for special chars such as $
$authPass = 'Password'

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
	foreach ($esxhost in (get-vmhost -Location $cluster | where {$_.ConnectionState -eq "Connected"})){
		Get-VMHostAuthentication -VMHost $esxhost | Set-VMHostAuthentication -Domain $domainname -User $authUser -Password $authPass -JoinDomain -confirm:$false
	}
}

Write-Output "Disconnecting from $vcenter"
Disconnect-VIServer $vcenter -confirm:$false
