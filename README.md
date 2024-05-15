# Intune Windows Firewall Rule Migration

This project aims to assist organizations in migrating their existing, in-house firewall rule solutions to Intune.


## Project specific notes

This project is primarily developed in PowerShell. This has the benefits of being flexible for organizations relying on many other Cmdlets and also serving as a
reference point to see how they can implement their own export Cmdlets to automate custom firewall rule migration.

Cmdlet development is done as [Script Cmdlets](https://devblogs.microsoft.com/powershell/fun-with-script-Cmdlets/) instead of traditional
Binary Cmdlets developed in C#.

### Project Structure

The project follows a slightly modified project structure pattern that is common in a few PowerShell repositories found online. An example
can be found [here](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/). Source code is all under the `/src` directory.

## Getting Started

### Operating System

The project has been developed and tested on Windows 10 1903 and with PowerShell Version 5.1.18362.145.

### Dependencies

This project relies on [Export-FirewallRules.ps1 Script](https://github.com/microsoft/Intune-PowerShell-Management/raw/master/Scenario%20Modules/Intune-FWRules-Migration/Export-FirewallRules.zip)
The script install the other dependencies the project relies on such as the[Intune PowerShell SDK](https://github.com/Microsoft/Intune-PowerShell-SDK) for submitting Graph API calls and the [ImportExcel Module](https://github.com/dfinke/ImportExcel).
1. Download and unzip the file [Export-FirewallRules.zip](https://github.com/microsoft/Intune-PowerShell-Management/raw/master/Scenario%20Modules/Intune-FWRules-Migration/Export-FirewallRules.zip).
2. Open a powershell session with administrative priviledge and run the script.

```PowerShell
Export-FirewallRule.ps1
```

### Running the tool

To run the tool, for each PowerShell session, you need to run the script `Export-FirewallRule.ps1`. This will download and install any prerequisites and import this project into your current PowerShell session by importing the module psm file:

```PowerShell
Export-FirewallRule.ps1
```
The user would be prompted to signin to their MSGraph admin account, asked to provide a unique migration profile name and asked permission to send telemetry to intune in a case where there was an exception thrown.

### Unit testing

This project uses [Pester](https://github.com/pester/Pester), a PowerShell unit-testing and mocking framework shipped natively with Windows 10.
While Pester is shipped with Windows 10, it is [best to update the package](https://github.com/pester/Pester#installation), as there are a
few syntax changes found between Pester versions.

To run unit tests for the entire project, you can simply run `Invoke-Pester .` in the `src\Tests` directory.

### Examples

For simple migration purposes for net firewall rules on the host, use this:

```PowerShell
Export-FirewallRule.ps1
```

This would by default export and send from [Group Policy Object](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/Policy/group-policy-objects) Firewall Rules that are enabled.

Exporting and sending rules from [Group Policy Object](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/Policy/group-policy-objects) Firewall Rules that are not enabled:

```PowerShell
Export-FirewallRule.ps1 -includeDisabledRules
```

Exporting and sending all of [Windows Defender Firewall with Advanced Security](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/windows-firewall-with-advanced-security) rules:

```PowerShell
Export-FirewallRule.ps1 -includeDisabledRules -includeLocalRules
```

By default, the `Export-FirewallRule.ps1` will export and send only  Group Policy Object Firewall rules, so the following command also works:

```PowerShell
Export-FirewallRule.ps1
```
- If a firewall rule has an attribute that is known to be incompatible with Intune beforehand. The tool will raise an exception, send telemetry data to Intune if permitted and automatically progress .
Once the tool has run, a report will be generated with rules that were not successfully migrated. You can view any of these rules by viewing RulesError.xlsx found in .\logs.

The following setting values are not supported for migration:

#### Ports

PlayToDiscovery is not supported as a local or remote port range


#### Address ranges

LocalSubnet6 is not supported as a local or remote address range
LocalSubnet4 is not supported as a local or remote address range
PlayToDevice is not supported as a local or remote address range

### Telemetry

Telemetry is not enabled by default. However, when the script is run a prompt is displayed asking permission to send telemetry to Intune. When the project encounters a firewall rule that is currently incompatible with Intune, if permission was granted, this error message is sent to the Intune team at Microsoft to help us refine the product.

