function Remove-JS7RepositoryItem
{
<#
.SYNOPSIS
Removes scheduling objects such as workflows, schedules etc. from a local Git repository

.DESCRIPTION
This cmdlet removes scheduling objects such as workflows, schedules etc. from a local Git repository.

The following REST Web Service API resources are used:

* /inventory/repository/delete

.PARAMETER Path
Specifies the folder and sub-folders of the scheduling object to be removed.

.PARAMETER Type
Specifies the object type which is one of:

* Any object type
** FOLDER
* Deployable object types:
** WORKFLOW
** FILEORDERSOURCE
** JOBRESOURCE
** NOTICEBOARD
** LOCK
* Releasable object types:
** INCLUDESCRIPT
** JOBTEMPLATE
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE
** REPORT

.PARAMETER Folder
Alternatively to use of -Path the parameter specifies a JOC Cockpit inventory folder to be used to
remove the respecive folder and objects from a local Git repository.

.PARAMETER Change
Specifies the identifier of an inventory change. Scheduling objects indicated with the change and
dependencies will be removed from JOC Cockpit's Git repository.

If in addition the -Folder parameter is used, then scheduling objects of the change will be limited
to objects located in the specified folder.

.PARAMETER Local
Specifies that a repository holding scheduling objects that are local to the environment should be used.
This corresponds to the LOCAL category. If this switch is not used then the
ROLLOUT category is assumed for a repository that holds scheduling objects
intended for rollout to later environments such as test, prod.

.PARAMETER NoReferencing
Specifies that no referencing objects from dependencies of objects subject to the indicated -Change should be included.

.PARAMETER NoReferences
Specifies that no references to objects from dependencies of objects subject to the indicated -Change should be included.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This parameter is not mandatory. However, the JOC Cockpit can be configured to require Audit Log comments for all interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7RepositoryItem -Folder /some_folder/some_sub_folder

Removes any scheduling objects from the indicated folder in the local "rollout" repository.

.EXAMPLE
Remove-JS7ReposioryItem -Path /some_folder/sampleWorkflow -Type 'WORKFLOW'

Removes the indicated worfklow "sampleWorkflow" from the local "rollout" repository.

.EXAMPLE
Remove-JS7ReposioryItem -Path /some_folder/sampleSchedule -Type 'SCHEDULE' -Local

Removes the indicated schedule "sampleSchedule" from the "local" repository.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','JOBTEMPLATE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','REPORT',IgnoreCase = $False)]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Change,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Local,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReferencing,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReferences,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$Path -and !$Folder -and !$Change )
        {
            throw "$($MyInvocation.MyCommand.Name): one of -Path, -Folder or -Change arguments is required"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $objectCount = 0
        $changes = @()
        $removableConfigurations = @()
    }

    Process
    {
        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }

        if ( $Path -and !$Type )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify the object type, use -Type parameter"
        }

        if ( $Path -and ($Type.count -gt 1) )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify a single object type, use -Type parameter"
        }

        if ( $Path -and $Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( !$Path -and !$Folder -and !$Change )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -Path or -Folder has to be used"
        }

        if ( $Change )
        {
            $changes += $Change
        } elseif ( $Path ) {
            $removableObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $removableObj
            Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $removableObj
        } else {
            $removableObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Folder -InputObject $removableObj
            Add-Member -Membertype NoteProperty -Name 'objectType' -value 'FOLDER' -InputObject $removableObj
        }

        if ( !$Change )
        {
            $removableConfigurationObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'configuration' -value $removableObj -InputObject $removableConfigurationObj

            $removableConfigurations += $removableConfigurationObj
        }
    }

    End
    {
        if ( $Local )
        {
            $category = 'LOCAL'
        } else {
            $category = 'ROLLOUT'
        }

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'category' -value $category -InputObject $body

        if ( $changes.count )
        {
            $changeItems = Get-JS7InventoryChange -Name $changes -Detailed

            if ( !$changeItems )
            {
                throw "$($MyInvocation.MyCommand.Name): no changes found"
            }

            $configurations = Get-JS7ConfigurationMerge -ChangeItems $changeItems -Dependencies (Get-JS7InventoryDependencies -OperationType DEPLOY -Folder $Folder -Configuration $changeItems.configurations -NoReferencing:$NoReferencing -NoReferences:$NoReferences)
            $objectCount = $configurations.configuration.count
            Add-Member -Membertype NoteProperty -Name 'configurations' -value $configurations -InputObject $body
        } else {
            $objectCount = $removableConfigurations.configuration.count
            Add-Member -Membertype NoteProperty -Name 'configurations' -value $removableConfigurations -InputObject $body
        }

        if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
        {
            $objAuditLog = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

            if ( $AuditTimeSpent )
            {
                Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
            }

            if ( $AuditTicketLink )
            {
                Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
            }

            Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
        }

        if ( $PSCmdlet.ShouldProcess( $Path, '/inventory/repository/delete' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/repository/delete' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-JSON )

                if ( !$requestResult.ok )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $objectCount -gt 0 )
            {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($objectCount) items deleted"
            } else {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items deleted"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
