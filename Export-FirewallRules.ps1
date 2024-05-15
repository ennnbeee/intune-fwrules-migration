
param([switch]$includeDisabledRules, [switch]$includeLocalRules)

## check for elevation
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity

if (!$principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host -ForegroundColor Red 'Error:  Must run elevated: run as administrator'
    Write-Host 'No commands completed'
    return
}

#----------------------------------------------------------------------------------------------C:\Users\t-oktess\Documents\powershellproject
if (-not(Test-Path '.\intune-fwrules-migration.zip')) {
    #Download a zip file which has other required files from the public repo on github
    Invoke-WebRequest -Uri 'https://github.com/ennnbeee/intune-fwrules-migration/raw/intune-fwrules-migration.zip' -OutFile '.\intune-fwrules-migration.zip'

    #Unblock the files especially since they are download from the internet
    Get-ChildItem '.\intune-fwrules-migration.zip' -Recurse -Force | Unblock-File

    #Unzip the files into the current direectory
    Expand-Archive -LiteralPath '.\intune-fwrules-migration.zip' -DestinationPath '.\'
}
#----------------------------------------------------------------------------------------------

## check for running from correct folder location

Import-Module '.\FirewallRulesMigration.psm1'
. '.\Intune-FWRules-Migration\Private\Strings.ps1'

$profileName = ''
try {
    $uri = 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?$filter=templateReference/TemplateFamily%20eq%20%27endpointSecurityFirewall%27'
    $json = Invoke-MgGraphRequest -Uri $uri -Method Get
    $profiles = $json.value
    $profileNameExist = $true
    $profileName = Read-Host -Prompt $Strings.EnterProfile
    while (-not($profileName)) {
        $profileName = Read-Host -Prompt $Strings.ProfileCannotBeBlank
    }
    while ($profileNameExist) {
        foreach ($display in $profiles) {
            $name = $display.name.Split('-')
            $profileNameExist = $false
            if ($name[0] -eq $profileName) {
                $profileNameExist = $true
                $profileName = Read-Host -Prompt $Strings.ProfileExists
                while (-not($profileName)) {
                    $profileName = Read-Host -Prompt $Strings.ProfileCannotBeBlank
                }
                break
            }
        }
    }
    $EnabledOnly = $true
    if ($includeDisabledRules) {
        $EnabledOnly = $false
    }

    if ($includeLocalRules) {
        Export-NetFirewallRule -ProfileName $profileName -CheckProfileName $false -EnabledOnly:$EnabledOnly -PolicyStoreSource 'All'
    }
    else {
        Export-NetFirewallRule -ProfileName $profileName -CheckProfileName $false -EnabledOnly:$EnabledOnly
    }

}
catch {
    $errorMessage = $_.ToString()
    Write-Host -ForegroundColor Red $errorMessage
    Write-Host 'No commands completed'
}


