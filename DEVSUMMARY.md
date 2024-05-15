# Getting Started

This document is made specifically to help developers get started with developing on the Intune Windows Firewall Rule Migration Tool.

# Set up and Configuration

1. Download/Clone the repo from [Github](https://github.com/microsoft/Intune-PowerShell-Management/archive/master.zip),[Script Download](https://github.com/microsoft/Intune-PowerShell-Management/raw/master/Scenario%20Modules/Intune-FWRules-Migration/Export-FirewallRules.zip) or from the Device Intent Repo.

2. Navigate to the directory where you downloaded or cloned the repo to. If you downloaded the repo from [Github](https://github.com/microsoft/Intune-PowerShell-Management/archive/master.zip, navigate to Scenario Modules/Intune-FWRules-Migration. If you are working with the Device Intent repo, navigate to [$DeviceIntentRoot]/src/tools/Intune-FWRules-Migration. If you downloaded the script directly, extract the folder.

# Running the Tool

To run the tool, for each PowerShell sessionv(run in admin mode), you need to run the script `Export-FirewallRule.ps1`. This will download, install and run any prerequisites and import this project into your current PowerShell session by importing the module psm file  (this is best if you downloaded the script directly through this link [Script Download](https://github.com/microsoft/Intune-PowerShell-Management/raw/master/Scenario%20Modules/Intune-FWRules-Migration/Export-FirewallRules.zip)):
:

```PowerShell
Export-FirewallRule.ps1
```
The user would be prompted to signin to their MSGraph admin account, asked to provide a unique migration profile name and asked permission to send telemetry to intune in a case where there was an exception thrown.

Note: If you run the above command you can skip the commands below.

Or

Run the following commad in a powershell session - run as administrator(this is best if you cloned the repo from Github or DI)

```PowerShell
Import-Module .\FirewallRulesMigration.psm1
```
Next Run

```PowerShell
Export-NetFirewallRule
```
You will be prompted to enter a profile name.
Note: The powershell session must be ran as administrator.

# Developing the tool
The tool uses a series of powershell commands to extract the firewall rules from your local machine, converts them to the Intune firewall rule format and sends them to Endpoint-Security. By default, the tool imports only enabled rules that are Group policy rules. You can change that by specifying with the options in the Export-NetFirewallRule function.

In the Intune-FWRules-Migration directory, there exist two folders, the private and a public folder. Each folder contains functions used in the importation of the firewall rules to endpoint security.

The public folders contains .ps1 files with major functions that do the work of extracting the firewallrules from your local machine, packaging the rules in a manner that is acceptable to endpoint security format and  sending it to endpoint-security.

The private folders contains helper functions that are imported to the public files to help with its functionality and telemetry.


## The following setting values are not supported for migration:

### Ports

PlayToDiscovery is not supported as a local or remote port range

### Address ranges

LocalSubnet6 is not supported as a local or remote address range
LocalSubnet4 is not supported as a local or remote address range
PlatToDevice is not supported as a local or remote address range

Once the tool has run, a report will be generated with rules that were not successfully migrated. You can view any of these rules by viewing RulesError.csv found in .\logs.


# Testing the Tool

When you make changes to the tool and you want to test it, you may not want the tool to import all of the rules in your machine because that can take sometime. In other for you to test the change you have made with just a few rules, when you run the Export-NetFirewallRule command, add the option `-Mode`, and use the tab to select the `Test` option.

```PowerShell
Export-NetFirewallRule -Mode Test
```
This would import only the first 20 rules from your machine. You can adjust this number to import more or less by editing the Get-SampleFirewallData.ps1 line 78 and 80. You change the number of rules and the range of rules by changing line 78 and 80 from the ps1 file.

# How to Deploy to Github
 1. Fork the [Github repo](https://github.com/microsoft/Intune-PowerShell-Management)
 2. Clone it to your local machine and then push your changes to the forked repo
 3. Create a PR to merge your changes to the microsoft repo. Dont forget to add you microsoft email to the signature when you create a PR for the first time.
 4. After creating the PR you can reach out to the contributors of the microsoft repo to approve the PR so it can be merged to the public repo. (Note: always have your code approved by the team first before pushing to the github repo. )
# Useful Links

1. [PM Documentation](https://microsoft-my.sharepoint-df.com/:w:/r/personal/mattsha_microsoft_com/_layouts/15/guestaccess.aspx?e=ZUxzZC&share=EfIKKv-5eQBKpIr_yQMEV_IB8nErYJZYC26YiIizNvGrwg)

2. [Windows FirewallRules](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/create-windows-firewall-rules-in-intune#local-ports)

3. [CSP Documentation](https://docs.microsoft.com/en-us/windows/client-management/mdm/firewall-csp)

4. [Github Repo](https://github.com/microsoft/Intune-PowerShell-Management)

