ScriptKit
=========

This is a collection of PowerCLI (PowerShell) scripts that VMware vSphere administrators can use in deploying and managing vSphere environments.

A brief description of each script in the current release is included below:

Configuration Scripts
---------------------
[VMware PowerCLI/Configure/create_vmotion_vmk.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/create_vmotion_vmk.ps1) -- Used to create vmk interfaces on ESX/ESXi hosts. The script by default creates two vmk interfaces per host, both enabled for vMotion. The script may be customised to enable other functions such as Management and iSCSI traffic per vmk interface. Requires [VMware PowerCLI/Configure/create_vmotion_vmk-list.csv](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/create_vmotion_vmk-list.csv) as input.

[VMware PowerCLI/Configure/host_auth_addto_ad_domain.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/host_auth_addto_ad_domain.ps1) -- Configure Host Authentication Services on hosts within the specified cluster to use a specified AD domain.

[VMware PowerCLI/Configure/set_vm_max_console_sessions.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/set_vm_max_console_sessions.ps1) -- Sets the maximum concurrent remote console sessions that are allowed to be opened to a VM. Requires [VMware PowerCLI/Configure/set_vm_max_console_sessions-list.csv](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/set_vm_max_console_sessions-list.csv) as input.

[VMware PowerCLI/Configure/set_vmhost_shell_timeout.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/set_vmhost_shell_timeout.ps1) -- Configures the ESXi shell time-out value.

[VMware PowerCLI/Configure/set_vmk_mtu.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/set_vmk_mtu.ps1) -- Configures the MTU values on the vmk interfaces mentioned in [VMware PowerCLI/Configure/set_vmk_mtu-list.csv](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/set_vmk_mtu-list.csv).

[VMware PowerCLI/Configure/Horizon View/set_viewSecurity_extIP.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Configure/Horizon%20View/set_viewSecurity_extIP.ps1) -- Updates the VMware View Security Server External IP address to reflect the current external internet connection IP address of the security server. Required for View Security Server deployments when a dynamic external IP address is in use.

Reporting Scripts
-----------------
[VMware PowerCLI/Reporting/report_HBAConfig.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_HBAConfig.ps1) -- Report on the HBA Link Speed, HBA Queue Depth, HBA Topology of each ESXi host.

[VMware PowerCLI/Reporting/report_ShellTimeOut.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_ShellTimeOut.ps1) -- Report on the ShellTimeOut Setting for all hosts in specified clusters/DC objects.

[VMware PowerCLI/Reporting/report_datastore_space.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_datastore_space.ps1) -- Script to return all datastores seen in vCenter as well as their capacity, used space and free space.

[VMware PowerCLI/Reporting/report_host_vmknics.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_host_vmknics.ps1) -- Report on the Management and vMotion IP Addresses (vmk).

[VMware PowerCLI/Reporting/report_host_wwn.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_host_wwn.ps1) -- Report WWN Numbers for hosts specified in $clusters

[VMware PowerCLI/Reporting/report_netConf_CDP.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_netConf_CDP.ps1) -- Report the current port group configuration as well as the discovered CDP information. Handy for comparing actual port group configuration with physical upstream switch configuration.

[VMware PowerCLI/Reporting/report_ntp_syslog.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_ntp_syslog.ps1) -- Report the configured NTP Servers as well as the Configured Syslog server.

[VMware PowerCLI/Reporting/report_snapshots.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_snapshots.ps1) -- Report on the virtual machine snapshots created for each virtual machine in the specified cluster.

[VMware PowerCLI/Reporting/report_vm_attached_media.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_vm_attached_media.ps1) -- Return all CD and Floppy Devices for each VM, including connection state.

[VMware PowerCLI/Reporting/report_vm_list.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Reporting/report_vm_list.ps1) -- Reports the Name, vCenter, Datacenter, Cluster, Host and Folder for every virtual machine visible within the PowerCLI session. Also works when connected to multiple VI servers. Output is saved to a CSV file as specified in $ReportFile. Helpful in large environments with many vCenter servers.

Testing Scripts
---------------
[VMware PowerCLI/Testing/test_host_vmotion.ps1](https://github.com/rynardtspies/ScriptKit/blob/master/VMware%20PowerCLI/Testing/test_host_vmotion.ps1) -- Test vMotion on all hosts in specified cluster by migrating a test VM between hosts at a set interval.
