@{

# Script module or binary module file associated with this manifest.
RootModule = 'JS7.psm1'

# Version number of this module.
ModuleVersion = '2.0.12.0'

# ID used to uniquely identify this module
GUID = '904a35e3-39b4-40bf-ab5f-e8c4ad5ae38d'

# Author of this module
Author = 'Andreas Pueschel'

# Company or vendor of this module
CompanyName = 'SOS GmbH'

# Copyright statement for this module
Copyright = 'Copyright (c) 2020 by SOS GmbH, licensed under GPL v3 License.'

# Description of the functionality provided by this module
Description = 'Manage and Control workflows and jobs with JS7 JobScheduler Controller and Agents, access the JS7 REST Web Service API'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Functions to export from this module
FunctionsToExport = @(
    'Add-JS7Folder',
    'Add-JS7GitCredentials',
    'Add-JS7InventoryItem',
    'Add-JS7Order',
    'Add-JS7SigningKey',
    'Confirm-JS7Order',
	'Connect-JS7',
    'Disable-JS7Agent',
    'Disable-JS7IAMAccount',
    'Disable-JS7Subagent',
    'Disconnect-JS7',
    'Enable-JS7Agent',
    'Enable-JS7IAMAccount',
    'Enable-JS7Subagent',
    'Export-JS7InventoryItem',
    'Import-JS7InventoryItem',
    'Get-JS7Agent',
    'Get-JS7AgentReport',
    'Get-JS7AgentStatus',
    'Get-JS7AuditLog',
    'Get-JS7Calendar',
    'Get-JS7CalendarDates',
    'Get-JS7ControllerInstance',
    'Get-JS7ControllerStatus',
    'Get-JS7ControllerVersion',
    'Get-JS7DailyPlanOrder',
    'Get-JS7DeployableItem',
    'Get-JS7FileTransferHistory',
    'Get-JS7FileTransferHistoryFile',
    'Get-JS7FileTransferItem',
    'Get-JS7GitCredentials',
    'Get-JS7IAMAccount',
    'Get-JS7IAMFolder',
    'Get-JS7IAMAccountPermission',
    'Get-JS7IAMPermission',
    'Get-JS7IAMRole',
    'Get-JS7IAMService',
    'Get-JS7InventoryItem',
    'Get-JS7InventoryStatistics',
    'Get-JS7ReleasableItem',
    'Get-JS7JOCInstance',
    'Get-JS7JOCLog',
    'Get-JS7JOCLogFilename',
    'Get-JS7JOCProperties',
    'Get-JS7JOCSettings',
    'Get-JS7Lock',
    'Get-JS7Notification',
    'Get-JS7Order',
    'Get-JS7OrderHistory',
    'Get-JS7OrderLog',
    'Get-JS7OrderSnapshot',
    'Get-JS7OrderSummary',
    'Get-JS7RepositoryItem',
    'Get-JS7Schedule',
    'Get-JS7SigningKey',
    'Get-JS7SubagentCluster',
    'Get-JS7SystemCredentials',
    'Get-JS7TaskHistory',
    'Get-JS7TaskLog',
    'Get-JS7Workflow',
    'Hide-JS7Agent',
    'Invoke-JS7ApiRequest',
    'Invoke-JS7GitRepositoryAdd',
    'Invoke-JS7GitRepositoryCheckout',
    'Invoke-JS7GitRepositoryClone',
    'Invoke-JS7GitRepositoryCommit',
    'Invoke-JS7GitRepositoryPull',
    'Invoke-JS7GitRepositoryPush',
    'Invoke-JS7IAMChangePassword',
    'Invoke-JS7IAMForcePasswordChange',
    'Invoke-JS7IAMResetPassword',
    'Invoke-JS7TestRun',
    'New-JS7ControllerInstance',
    'New-JS7DailyPlanOrder',
    'New-JS7SigningKey',
    'New-JS7Subagent',
    'Publish-JS7Agent',
    'Publish-JS7ClusterAgent',
    'Publish-JS7DeployableItem',
    'Publish-JS7ReleasableItem',
    'Publish-JS7SubagentCluster',
    'Remove-JS7Agent',
    'Remove-JS7CompletedOrder',
    'Remove-JS7DailyPlanOrder',
    'Remove-JS7DailyPlanSubmission',
    'Remove-JS7FileTransferItem',
    'Remove-JS7Folder',
    'Remove-JS7GitCredentials',
    'Remove-JS7IAMAccount',
    'Remove-JS7IAMFolder',
    'Remove-JS7IAMPermission',
    'Remove-JS7IAMRole',
    'Remove-JS7IAMService',
    'Remove-JS7InventoryItem',
    'Remove-JS7RepositoryItem',
    'Remove-JS7Subagent',
    'Remove-JS7SubagentCluster',
    'Rename-JS7Folder',
    'Rename-JS7IAMAccount',
    'Rename-JS7IAMFolder',
    'Rename-JS7IAMPermission',
    'Rename-JS7IAMRole',
    'Rename-JS7IAMService',
    'Rename-JS7InventoryItem',
    'Reset-JS7Agent',
    'Reset-JS7Subagent',
    'Restart-JS7ControllerInstance',
    'Restart-JS7JOCService',
    'Restore-JS7Agent',
    'Restore-JS7Folder',
    'Restore-JS7InventoryItem',
    'Resume-JS7Order',
    'Revoke-JS7ClusterAgent',
    'Revoke-JS7SubagentCluster',
	'Send-JS7Mail',
    'Set-JS7Agent',
    'Set-JS7ClusterAgent',
    'Set-JS7Controller',
    'Set-JS7Credentials',
    'Set-JS7Option',
    'Show-JS7Agent',
    'Set-JS7FileTransferItem',
    'Set-JS7IAMAccount',
    'Set-JS7IAMFolder',
    'Set-JS7IAMPermission',
    'Set-JS7IAMRole',
    'Set-JS7IAMService',
    'Set-JS7InventoryItem',
    'Set-JS7JOCSettings',
    'Set-JS7RepositoryItem',
    'Set-JS7Subagent',
    'Set-JS7SubagentCluster',
    'Start-JS7ExecutableFile',
    'Start-JS7Order',
    'Stop-JS7ControllerInstance',
    'Stop-JS7DailyPlanOrder',
    'Stop-JS7Order',
    'Submit-JS7DailyPlanOrder',
    'Suspend-JS7Order',
    'Switch-JS7ControllerInstance',
    'Switch-JS7JOCInstance',
    'Test-JS7ControllerInstance',
    'Update-JS7FromRepositoryItem'
)

# # Cmdlets to export from this module
# CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = @()

# # Aliases to export from this module
# AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

PrivateData = @{
    # PSData is module packaging and gallery metadata embedded in PrivateData
    # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
    # We had to do this because it's the only place we're allowed to extend the manifest
    # https://connect.microsoft.com/PowerShell/feedback/details/421837
    PSData = @{
        # The primary categorization of this module (from the TechNet Gallery tech tree).
        Category = "Scripting Techniques"

        # Keyword tags to help users find this module via navigations and search.
        Tags = @('PSEdition_Desktop','PSEdition_Core','Windows','Linux','MacOS','Cmdlet','Workflow','JobScheduler','JS7','Scheduling','Workload-Automation')

        # The web address of an icon which can be used in galleries to represent this module
        IconUri = "https://kb.sos-berlin.com/download/attachments/3638359/JS7_blue_orange_on_white.png?api=v2"

        # The web address of this module's project or support homepage.
        ProjectUri = "https://kb.sos-berlin.com/x/PpQwAw"

        # The web address of this module's license. Points to a page that's embeddable and linkable.
        LicenseUri = "https://www.gnu.org/licenses/gpl-3.0.en.html"

        # Release notes for this particular version of the module
        # ReleaseNotes = False

        # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
        # RequireLicenseAcceptance = ""

        # Indicates this is a pre-release/testing version of the module.
        IsPrerelease = 'False'
    }
}

# HelpInfo URI of this module
HelpInfoURI = 'https://kb.sos-berlin.com/x/fpQwAw'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
