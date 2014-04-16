# This file is part of ScriptKit.
#
#    ScriptKit is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    ScriptKit is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with ScriptKit.  If not, see <http://www.gnu.org/licenses/>
#
#===================================================================================
#VMware Horizon View: Update Security Server External URL/IP Address
#Author:  Gabrie van Zanten (www.gabesvirtualworld.com)
#Author URL: http://www.gabesvirtualworld.com/enabling-vmware-view-4-6-pcoip-with-dynamic-ip-address/
#Description: Updates the External IP address refernece in VMware Horizon View to
# match the current public IP address of the security server.
# Run this script on the View Connection Server
#Version 1.01
#Tested on: VMware Horizon View 5.x
#Copyright (c) 2011 - 2014 Gabrie van Zanten
#==================================================================================

Add-PSSnapin VMware.VimAutomation.Core 
Add-PSSnapin VMware.View.Broker 
  
# Name of the Security Server 
$SecurityServer = "VIEWSecurityServerNameHere"

$LogFile = "C:\Temp\set_viewSecurity_extIP.log"
  
# For logging creating a timestamp 
$TimeStamp = Get-Date -format yyyy-MM-dd-H-mm
  
# Filling $CheckedIP with the external IP address, using whatismyip.com service 
$wc = New-Object net.WebClient 
$CheckedIP = $wc.downloadstring("http://bot.whatismyipaddress.com") 

# Now check the current ExternalPCoIPURL entry 
$CurrentSettings = Get-ConnectionBroker
ForEach ($ConnectionBroker in $CurrentSettings){
	if ($ConnectionBroker.broker_id -eq $SecurityServer) {
		$CurrentIP = $ConnectionBroker.externalPCoIPURL
		}
	}
  
# Check if $CurrentIP starts with the IP address from $CheckedIP 
# Used StartsWith because $CurrentIP has port address at the end 
$Result = $CurrentIP.StartsWith($CheckedIP)
  
# Are IP address the same? 
If ($Result) 
{ 
     # Yes, both IP addresses are the same, do nothing, only write a log entry 
     $row = $TimeStamp + "," + $CheckedIP + "," + $CurrentIP + ",nochange"
} 
else 
{ 
    # External IP is not equal to IP set in externalPCoIPURL 
    # Changing the externalPCoIPURL 
    Update-ConnectionBroker -broker_id $SecurityServer -externalPCoIPURL $CheckedIP
  
    # Check if it was successful 
    $NewSettings = Get-ConnectionBroker
    $row = $TimeStamp + "," + $CheckedIP + "," + $CurrentIP + "," + $NewSettings.externalPCoIPURL 
} 
$row | Out-File -FilePath $LogFile -Append