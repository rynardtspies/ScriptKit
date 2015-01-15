'# This file is part of ScriptKit.
'#
'#    ScriptKit is free software: you can redistribute it and/or modify
'#    it under the terms of the GNU General Public License as published by
'#    the Free Software Foundation, either version 3 of the License, or
'#    (at your option) any later version.
'#
'#    ScriptKit is distributed in the hope that it will be useful,
'#    but WITHOUT ANY WARRANTY; without even the implied warranty of
'#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'#    GNU General Public License for more details.
'#
'#    You should have received a copy of the GNU General Public License
'#    along with ScriptKit.  If not, see <http://www.gnu.org/licenses/>
'#
'#=================================================================================================
'#Author: Rynardt Spies
'#Author Contact: rynardt.spies@virtualvcp.com / www.virtualvcp.com / @rynardtspies
'#Updated: January 2015
'#Version: 1.00.00
'#Script Language: VBScript
'#Relies on: WSscript, WMI
'#Description: Report logical disk information such as drive letters, size, used and free space for each logical disk 
'#for servers included in the servers.txt file.
'#Copyright (c) 2014 - 2015 Rynardt Spies
'#===================================================================================================

On Error Resume Next

Const ForReading = 1
'###################################################
'IMPORTANT: Set these variables before execution
'###################################################
strInFile = "servers.txt"
strOutFile = "d:\GetDiskInfo\Report.csv"

'setup input file to read servernames from
Set objFSO = CreateObject("Scripting.FileSystemObject")

'Check if the input file exists
If not objFSO.FileExists(strInFile) THEN
	wscript.echo "Please create a file named 'servers.txt' with one server name per line, with a hard return at the end of each line."
	wscript.quit
end if

'Script got this far, so let's read the input file
Set objInputFile = objFSO.OpenTextFile(strInFile, ForReading)

Set arrServerList = CreateObject( "System.Collections.ArrayList" )
Do Until objInputFile.AtEndOfStream
    strNextLine = objInputFile.Readline
    arrServerList.Add strNextLine
Loop

'Close the input file
objInputFile.Close

'setup output file
Set objFS = CreateObject("Scripting.FileSystemObject")
Set objOutFile = objFS.CreateTextFile(strOutFile,True)
'Write the header row in the output file
objOutFile.WriteLine("ServerName, WMISystemName , DiskCaption, DiskCompressed, DiskDescription, DiskDeviceID, DiskFileSystem, DiskSizeGB, DiskUsedSpaceGB, DiskFreeSpaceGB, DiskName, DiskVolumeName, ")

Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20

'Process the server list
For Each strServer In arrServerList
	WScript.Echo "Processing... " & strServer
   'for the current server, create a WMISevice and get the logical disk information from WMI
   Set objWMIService = GetObject("winmgmts:\\" & strServer & "\root\CIMV2")
   Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk", "WQL", _
   wbemFlagReturnImmediately + wbemFlagForwardOnly)

   'for all of the WMI items returned, write the selected data to the output file
   For Each objItem In colItems
      objOutFile.WriteLine(" " & strServer & ", " & objItem.SystemName & ", " & objItem.Caption & ", " & objItem.Compressed & ", " & objItem.Description & ", " & objItem.DeviceID & ", " & objItem.FileSystem & ", " & (objItem.Size/1024)/1024 & ", " & ((objItem.Size-objItem.FreeSpace)/1024)/1024 & ", " & (objItem.FreeSpace/1024)/1024 & ", " & objItem.Name & ", " & objItem.VolumeName)
   Next
Next

'close output file
objOutFile.Close

WScript.Echo "End of scripted tasks."