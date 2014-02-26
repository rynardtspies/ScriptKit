#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Report the current port group configuration as well as the discovered CDP information.
#Handy for comparing actual portgroup config with physical upstream switch config
#Tested with: VMware PowerCLI 5.5 Release 1.

#NOTE: This script needs to be updated to better display dvSwitch components
#===================================================================================

#Specify some variable values first
$vcenter = "vcenter.domain"
$clusters = @("Cluster01","Cluster02","Cluster03")
$reportdate = Get-Date -Format "dd-MM-yyyy"
$starttime = (Get-Date -f "HH:MM")
#Specify the report file WITHOUT .csv file extension. This will be added later by the script
$reportfile = "C:\TEMP\report_netConf_CDP"

Write-Output "Getting the Network Configuration from $datacenterObj"

#Clear the console screen
Clear Screen

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"
Write-Output "The system time is now $starttime on $reportdate"

$report = @()
foreach ($cluster in $clusters){
	#Test if the current $cluster exists in the environment. If it doesn't continue to next $cluster
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Cluster $cluster could not be found"
		Continue
	}
	foreach($esxHost in (Get-VMHost -Location $datacenterObj | where {$_.ConnectionState -eq "Connected"} | sort $_.Name)){ 
		$esx = $esxHost | Get-View
		Write-Output "Getting Network Information for '$esxHost'..."
		$netSys = Get-View $esx.ConfigManager.NetworkSystem
		foreach($pnic in $esx.Config.Network.Pnic){
			$vSw = $esxHost | Get-VirtualSwitch | where {$_.Nic -contains $pNic.Device}
			$pg = $esxHost | Get-VirtualPortGroup | where {$_.VirtualSwitchName -eq $vSw.Name}
			$order = ($esx.Config.Network.Vswitch | where {$_.Name -eq $vSw.Name}).Spec.Policy.NicTeaming.NicOrder
			$cdpInfo = $netSys.QueryNetworkHint($pnic.Device)
			$row = "" | Select Hostname,pNic,pNicModel,vSwitch,Portgroups,PortGroupVLANs,Speed,Status,PCI,ActiveStanByUnassigned,IPrange,pSwitch,PortID,VLANID
				$row.HostName = $esxHost.Name
				$row.pNic = $pnic.Device 
				$row.pNicModel = &{($esx.Hardware.PciDevice | where {$_.Id -eq $pnic.Pci}).DeviceName}
				$row.vSwitch = $vSw.Name
				$row.Portgroups = &{if($pg){[string]::Join(", ", ($pg | %{$_.Name}))}}
				$row.PortGroupVLANs = &{if($pg){[string]::Join(", ", ($pg | %{$_.vlanid}))}}
				$row.Speed = $pnic.LinkSpeed.SpeedMb
				$row.Status = &{if($pnic.LinkSpeed -ne $null){"up"}else{"down"}}
				$row.PCI = $pnic.Pci
				$row.ActiveStanByUnassigned = &{if($order.ActiveNic -contains $pnic.Device){"active"}elseif($order.StandByNic -contains $pnic.Device){"standby"}else{"unused"}}
				$row.IPrange = &{[string]::Join("/",@($cdpInfo[0].Subnet | %{$_.IpSubnet + "(" + $_.VlanId + ")"}))}
				$row.pSwitch = &{if($cdpInfo[0].connectedSwitchPort){$cdpInfo[0].connectedSwitchPort.devId}else{"CDP not configured"}}
				$row.PortID = &{if($cdpInfo[0].connectedSwitchPort){$cdpInfo[0].connectedSwitchPort.portId}else{"CDP not configured"}}
				$row.VLANID = &{if($cdpInfo[0].connectedSwitchPort){$cdpInfo[0].connectedSwitchPort.Vlan}else{"CDP not configured"}}
				$report += $row
		}
	}
}

$endDate = Get-Date -Format "dd-MM-yyyy"
$endTime = (Get-Date -f "HH-MM")

$reportfile = $reportfile+"-"+$endDate+"-"+$endTime+".csv"
Write-Output "Writing Report Information to '$reportfile' "
$report | export-csv $reportfile -NoTypeInformation

Write-Output "Disconnecting from Server: '$vcenter'..."
Disconnect-VIServer $vcenter -confirm:$false

