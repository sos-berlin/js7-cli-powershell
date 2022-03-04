function Update-JS7FromRepositoryItem
{
<#
.SYNOPSIS
Updates the JS7 inventory from scheduling objects in a local Git repository.

.DESCRIPTION
This cmdlet updates scheduling objects such as a workflows, schedules etc. in the JS7 inventory from a local Git repository.

Existing scheduling objects in the JS7 inventory are created or are updated if they exist.

.PARAMETER Path
Specifies the folder and sub-folders of the repository from which objects are selected for update of the JS7 inventory.

.PARAMETER Type
Specifies the scheduling object type that is one of:

* Any object type
** FOLDER
* Deployable object types
** WORKFLOW
** FILEORDERSOURCE
** JOBRESOURCE
** NOTICEBOARD
** LOCK
* Releasable object types
** INCLUDESCRIPT
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE

If no object type is specified then any deployable object types will be used.

.PARAMETER Local
Specifies that a repository holding local scheduling objects should be used.
This corresponds to the LOCAL category. If this switch is not used then then
ROLLOUT category is assumed for a repository that holds scheduling objects
intended for rollout to later environments such as test, prod.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined objects as for example from the Get-JS7RepositoryItem cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Update-JS7RepositoryItem -Path /some_folder/samples -Type 'FOLDER'

Updates the JS7 inventory from the indicated folder in the local Git repository of category ROLLOUT.
Depending on the JS7 Settings in use this can include workflows, resource locks etc.

.EXAMPLE
Update-JS7RepositoryItem -Path /some_folder/samples -Type 'FOLDER' -Local

Updates the JS7 inventory from the indicated folder in the local Git repository of category LOCAL.
Depending on the JS7 Settings in use this can include calendars, schedules etc.

.EXAMPLE
Update-JS7RepositoryItem -Path /some_folder/samples/sampleWorkflow -Type 'WORKFLOW'

Updates the JS7 inventory from the indicated worfklow in the local Git repository.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Local,
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

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $updatableConfigurations = @()
    }

    Process
    {
        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }

        if ( $Path.endsWith('/') )
        {
            $Path = $Path.Substring( 0, $Path.Length-1 )
        }

        if ( $Path -and !$Type )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify the object type, use -Type parameter"
        }

        if ( $Path -and $Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( !$Path -and !$Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -Path or -Folder has to be used"
        }

        if ( $Path )
        {
            $updatableObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $updatableObj
            Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $updatableObj

        } else {
            $updatableObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Folder -InputObject $updatableObj
            Add-Member -Membertype NoteProperty -Name 'objectType' -value 'FOLDER' -InputObject $updatableObj
        }

        $updatableConfigurationObj = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'configuration' -value $updatableObj -InputObject $updatableConfigurationObj
        $updatableConfigurations += $updatableConfigurationObj
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
        Add-Member -Membertype NoteProperty -Name 'configurations' -value $updatableConfigurations -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'category' -value $category -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( $Path, '/inventory/repository/update' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/repository/update' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): object updated: $Path"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
