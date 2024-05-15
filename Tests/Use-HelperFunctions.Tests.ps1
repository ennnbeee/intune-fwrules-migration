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

. "$($PathToScript)\..\Intune-FWRules-Migration\Private\Use-HelperFunctions.ps1"
. "$PathToScript\..\Intune-FWRules-Migration\Private\Strings.ps1"

Describe "Show-OperationProgress" {
    It "Should call Write-progress and return a decremented remaining value" {
        Mock Write-Progress
        Show-OperationProgress -remainingObjects 10 -totalObjects 10 -activityMessage "foo" | Should -Be 9
        Assert-MockCalled Write-Progress
    }

    It "Should throw an exception if given non-positive total objects" {
        For ($i = -10; $i -le 0; $i++) {
            { Show-OperationProgress `
                -remainingObjects 0 `
                -totalObjects $i `
                -activityMessage "foo" } | Should -Throw $Strings.ShowOperationProgressException
        }
    }
}