#Author: Rynardt Spies
#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
#Version: v1.00.00
#Updated: February 2014
#Report the configured NTP Servers as well as the Configured Syslog server


$vcenter = "vcenter.domain"
$clusters = @("Cheshunt")
$ReportFile = "C:\ntp_syslog_report.csv"

Write-Output ("Connecting to vCenter server: $vcenter")
connect-viserver $vcenter

$report = @()


foreach ($cluster in $clusters) {
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
