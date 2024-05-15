# Debugging
$PathToScript = if ( $PSScriptRoot ) {
    # Console or vscode debug/run button/F5 temp console
    $PSScriptRoot
}
Else {
    if ( $psISE ) { Split-Path -Path $psISE.CurrentFile.FullPath }
    else {
        if ($profile -match 'VScode') {
            # vscode "Run Code Selection" button/F8 in integrated console
            Split-Path $psEditor.GetEditorContext().CurrentFile.Path
        }
        else {
            Write-Output 'unknown directory to set path variable. exiting script.'
            break
        }
    }
}

# Reads values from the module manifest file
$manifestData = Import-PowerShellDataFile -Path "$($PathToScript)\Intune-FWRules-Migration.psd1"

# Sets scopes for Graph
$scopes = 'DeviceManagementConfiguration.ReadWrite.All,DeviceManagementManagedDevices.ReadWrite.All'

#Installing dependencies if not already installed [Microsoft.Graph] and [ImportExcel]
#from the powershell gallery
if (-not(Get-Module Microsoft.Graph -ListAvailable)) {
    Write-Host 'Installing Microsoft Graph PowerShell module from Powershell Gallery...'
    try {
        Install-Module Microsoft.Graph -Force
    }
    catch {
        Write-Host "Intune Microsoft Graph PowerShell module was not installed successfully... `r`n$_"
    }

}
if (-not(Get-Module ImportExcel -ListAvailable)) {
    Write-Host 'Installing ImportExcel Module from Powershell Gallery...'
    try {
        Install-Module ImportExcel -Force
    }
    catch {
        Write-Host "ImportExcel Module Powershell was not installed successfully... `r`n$_"
    }
}
# Ensure required modules are imported
ForEach ($module in $manifestData['RequiredModules']) {
    If (!(Get-Module $module)) {
        # Setting to stop will cause a terminating error if the module is not installed on the system
        Import-Module $module -ErrorAction Stop
    }
}

# Port all functions and classes into this module
$Public = @( Get-ChildItem -Path "$($PathToScript)\Intune-FWRules-Migration\Public\*.ps1" -ErrorAction SilentlyContinue -Recurse )

# Load each public function into the module
ForEach ($import in @($Public)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Exports the cmdlets provided in the module manifest file, other members are not exported
# from the module
ForEach ($cmdlet in $manifestData['CmdletsToExport']) {
    Export-ModuleMember -Function $cmdlet
}

if (Get-Module Microsoft.Graph -ListAvailable) {
    try {
        # Connect to Graph
        If ($IsMacOS -or $IsWindows) {
            Connect-MgGraph -Scopes $scopes -UseDeviceAuthentication
            Write-Host 'Disconnecting from Graph to allow for changes to consent requirements'
            Disconnect-MgGraph
            Write-Host 'Connecting to Graph' -ForegroundColor Cyan
            Connect-MgGraph -Scopes $scopes -UseDeviceAuthentication

        }
        Else {
            Connect-MgGraph -Scopes $scopes
            Write-Host 'Disconnecting from Graph to allow for changes to consent requirements'
            Disconnect-MgGraph
            Write-Host 'Connecting to Graph'
            Connect-MgGraph -Scopes $scopes -UseDeviceAuthentication
        }

        $graphDetails = Get-MgContext
        if ($null -eq $graphDetails) {
            Write-Host "Not connected to Graph, please review any errors and try to run the script again' cmdlet."
        }
    }
    catch {
        $errorMessage = $_.ToString()
        Write-Host -ForegroundColor Red 'Error:'$errorMessage
        return
    }

}