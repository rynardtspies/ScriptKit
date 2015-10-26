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
#Updated: October 2015
#Version: 1.00.00
# Description:	Script to delete all Hyperic Adapter objects related to servers listed in inputlist.csv,
# from vROPS 6.x inventory
# Use at own risk.
#Tested with: Microsoft PowerShell 4.0
#Copyright (c) 2015 Rynardt Spies
#===========================================================================================
$vropsurl = "https://<VROPS_FQDN>/suite-api/api/resources"

#IMPORTANT!!!!!
#Please ensure that the first line in input.csv matches SERVERNAME. Failure to do so will result in the incorrect objects being deleted from vROPS.
$serverlist = Import-CSV C:\Temp\inputlist.csv

$creds = Get-Credential -Username admin -Message "Please enter the password for the vROPS admin account..."

Clear

foreach ($server in $serverlist){
	$myserver = $server.servername
	write-output "Finding Hyperic Objects for $myserver"
	
	$currentURL = $vropsurl + "?name=$myserver&AdapterKind=HypericApiAdapter"
	$currentObj = Invoke-RestMethod -Method GET -uri $currenturl -Credential $creds -Header @{ "Accept" = "application/json" }
	
	foreach ($res in $currentObj.ResourceList){
		$resname = $res.resourceKey.Name
		$resid = $res.Identifier
		Write-Output "Deleting object $resid ($resname)"
		Invoke-RestMethod -Method DELETE -uri "$vropsurl/$resid" -Credential $creds
	}
}