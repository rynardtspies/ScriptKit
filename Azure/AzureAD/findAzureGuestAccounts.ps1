#Description: Find and optionally disable all guest accounts in an Azure Account 
#Required PSModules: AzureAD
#Author: Rynardt Spies
#Date: 09/03/2019


#Pass -DisableAllGuestAccounts:$true to enable all guest accounts. Use with caution.
param (
    [switch]$DisableAllGuestAccounts = $false #Pass -DisableAllGuestAccounts:$true as a script parameter to enable all guest accounts. Use with caution.
)

$users = Get-AzureADUser

foreach ($user in $users){
    if ($user.UserType -eq "Guest"){
        Write-Output($user.DisplayName + " is a guest user. UserPrincipal: " + $user.UserPrincipalName + ". AccountEnabled: " +$user.AccountEnabled);
        if ($DisableAllGuestAccounts){
            Write-Output("Disabling guest account: " + $user.UserPrincipalName);
            Set-AzureADUser -ObjectId $user.ObjectId -AccountEnabled:$false
            $UpdatedUser = Get-AzureADUser -ObjectId $user.ObjectId
            Write-Output("Guest Account: " + $UpdatedUser.DisplayName + " AccountEnabled: " + $UpdatedUser.AccountEnabled)
        }
    }
} 
