#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: February 2014
#Description: Add hosts in cluster to a specified AD Domain.

$vcenter = "vcenter.domain"
$clustername = @("cluster1","cluster2")
$domainname = "addomain"
$authUser = "aduser"
$authPass = 'aduserpassword'

Write-Output "Connecting to vCenter $vcenter"
connect-viserver $vcenter

foreach ($esxhost in (get-vmhost -Location $clustername | where {$_.ConnectionState -eq "Connected"})){
	Get-VMHostAuthentication | Set-VMHostAuthentication -Domain $domainname -User $authUser -Password $authPass -JoinDomain -confirm:$false
	}

Write-Output "Disconnecting from $vcenter"
Disconnect-VIServer $vcenter -confirm:$false
