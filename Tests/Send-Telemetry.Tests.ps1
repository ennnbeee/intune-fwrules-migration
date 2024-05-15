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

. "$PSScriptRoot\..\Intune-FWRules-Migration\Private\Send-Telemetry.ps1"
. "$PSScriptRoot\..\Intune-FWRules-Migration\Private\Strings.ps1"

Describe "Send Telemetry Test Cases" {
    Context "Send-ConvertToIntuneFirewallRuleTelemetry" {
        It "Should call Send-FailureTelemetry with a 'ConvertToIntuneFirewallRule' category" {
            Mock Send-FailureTelemetry

            Send-ConvertToIntuneFirewallRuleTelemetry "foo"

            Assert-MockCalled Send-FailureTelemetry -ParameterFilter { $category -eq "ConvertToIntuneFirewallRule" } -Times 1 -Exactly
        }
    }

    Context "Send-IntuneFirewallRuleTelemetry" {
        It "Should call Send-FailureTelemetry with a 'IntuneFirewallRuleGraph' category" {
            Mock Send-FailureTelemetry

            Send-IntuneFirewallGraphTelemetry "foo"

            Assert-MockCalled Send-FailureTelemetry -ParameterFilter { $category -eq "IntuneFirewallRuleGraph" } -Times 1 -Exactly
        }
    }
}

Describe "Get-IntuneFirewallRuleErrorTelemetryChoice" {
    It "Should return '$($Strings.Yes)' if given the -sendErrorTelemetryInitialized is passed with a true value" {
        Get-IntuneFirewallRuleErrorTelemetryChoice -telemetryMessage "foo" -sendErrorTelemetryInitialized $true | Should -Be "Yes"
    }

    It "Should return '$($Strings.Yes)' if user selected '$($Strings.Yes)'" {
        Mock Get-UserPrompt -MockWith { return 0 }
        Get-IntuneFirewallRuleErrorTelemetryChoice -telemetryMessage "foo" | Should -Be $Strings.Yes
    }

    It "Should return '$($Strings.No)' if user selected '$($Strings.No)'" {
        Mock Get-UserPrompt -MockWith { return 1 }
        Get-IntuneFirewallRuleErrorTelemetryChoice -telemetryMessage "foo" | Should -Be $Strings.No
    }

    It "Should return '$($Strings.YesToAll)' if user selected '$($Strings.YesToAll)'" {
        Mock Get-UserPrompt -MockWith { return 2 }
        Get-IntuneFirewallRuleErrorTelemetryChoice -telemetryMessage "foo" | Should -Be $Strings.YesToAll
    }

    It "Should return '$($Strings.Continue)' if user selected '$($Strings.Continue)'" {
        Mock Get-UserPrompt -MockWith { return 3 }
        Get-IntuneFirewallRuleErrorTelemetryChoice -telemetryMessage "foo" | Should -Be $Strings.Continue
    }
}
