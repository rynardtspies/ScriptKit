#Description: Find and optionally disable all guest accounts in an Azure Account 
#Required PSModules: AzureAD
#Author: Rynardt Spies
#Date: 09/03/2019

#Set to true to automatically disable guest accounts found
$DisableAllGuestAccounts = $false

$Report = @()
$UpdatedUser = ""

#The following code snippet enables us to connect to AzureAD from an Automation Runbook.
#Code published by: http://www.gi-architects.co.uk/2017/02/azure-ad-authentication-connect-azuread-in-azure-automation/

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    Write-Output("Logging in to Azure Active Directory")

    Connect-AzureAD `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


##Back to our code:

$users = Get-AzureADUser

foreach ($user in $users){
    if ($user.UserType -eq "Guest"){
        Write-Output($user.DisplayName + " is a guest user. UserPrincipal: " + $user.UserPrincipalName + ". AccountEnabled: " +$user.AccountEnabled)
        if ($DisableAllGuestAccounts){
            Write-Output("Disabling guest account: " + $user.UserPrincipalName)
            Set-AzureADUser -ObjectId $user.ObjectId -AccountEnabled:$false
            $UpdatedUser = Get-AzureADUser -ObjectId $user.ObjectId
            Write-Output("Guest Account: " + $UpdatedUser.DisplayName + " AccountEnabled: " + $UpdatedUser.AccountEnabled)
        }
        if ($UpdatedUser.ObjectId -ne $user.ObjectId){
            $UpdatedUser = Get-AzureADUser -ObjectId $user.ObjectId
        }

        #Add the current user to the Report Array
        $row = "" | select-object DisplayName, UserPrincipalName, AccountEnabled
        $row.DisplayName = $UpdatedUser.DisplayName
        $row.UserPrincipalName = $UpdatedUser.UserPrincipalName
        $row.AccountEnabled = $UpdatedUser.AccountEnabled
        $Report += $row
    }
}
Write-Output($Report); 
