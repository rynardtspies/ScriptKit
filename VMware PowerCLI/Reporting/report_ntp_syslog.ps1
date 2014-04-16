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
#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.01
#Updated: February 2014
#Report the configured NTP Servers as well as the Configured Syslog server
#Tested with: VMware PowerCLI 5.5 Release 1.
#Copyright (c) 2014 Rynardt Spies
#===================================================================================

$vcenter = "vcenter.domain"
$clusters = @("Cluster01","Cluster02")
$ReportFile = "C:\TEMP\report_ntp_syslog-report.csv"

write-Output "Connecting to vSphere Environment $vcenter"
#Try to connect to $vcenter. If not, fail gracefully with a message
if (!($ConnectionResult = Connect-VIServer $vcenter -ErrorAction SilentlyContinue)){
	Write-Output "Could not connect to $vcenter. Check server address."
	break
	}
Write-Output "Successfully connected to: $ConnectionResult"

$report = @()
foreach ($cluster in $clusters){
	#Test if the current $cluster exists in the environment. If it doesn't continue to next $cluster
	if(!(Get-Cluster $cluster -ErrorAction SilentlyContinue)){
		Write-Output "Cluster $cluster could not be found"
		Continue
	}
	foreach ($esxhost in (Get-VMhost -Location $cluster)){
		$ntpservers = Get-VMhostNTPServer -VMhost $esxhost
        $ntpstring = foreach ($ntpserver in $ntpservers) {$ntpserver + ","}
        $ntpstatus = Get-VMhostService $esxhost | where {$_.key -like "ntpd"}
        $syslogserver = Get-VMHostSyslogServer -VMhost $esxhost
        $row = "" | select Hostname, SyslogServer, NTPRunning, NTPServers
        $row.Hostname = $esxhost.name
        $row.SyslogServer = $syslogserver
        $row.NTPRunning = $ntpstatus.running
        $row.NTPServers = [string]$ntpstring
        $report += $row
    }
}

Write-Output "Writing report to $ReportFile"
$report | export-csv $ReportFile -NoTypeInformation

Write-Output "Disconnecting from $vcenter"
Disconnect-VIServer $vcenter -confirm:$false