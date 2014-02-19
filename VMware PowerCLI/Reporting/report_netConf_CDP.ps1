#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: February 2014
#Report the current port group configuration as well as the discovered CDP information.
#Handy for comparing actual portgroup config with physical upstream switch config

#Specify some variable values first
$vcenterServer = "vcenter.domain"
$datacenterObj = "DatacenterName"
$reportdate = Get-Date -Format "dd-MM-yyyy"
$starttime = (Get-Date -f "HH:MM")

#Connect to the vCenter Server
Write-Output "Getting the Network Configuration from $datacenterObj"
Write-Output "The system time is now $starttime on $reportdate"
Write-Output "Trying to connect to '$vcenterServer'..."
Connect-VIServer $vcenterServer

$report = @()
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
$endDate = Get-Date -Format "dd-MM-yyyy"
$endTime = (Get-Date -f "HH-MM")
Write-Output "Getting the current date and time: $endDate $endTime"
$outfile = "report_netConf_CDP-"+$endDate+"-"+$endTime+".csv"

Write-Output "Writing Report Information to '$outfile' "
$report | export-csv $outfile -NoTypeInformation

Write-Output "Disconnecting from Server: '$vcenterServer'..."
Disconnect-VIServer $vcenterServer -confirm:$false

