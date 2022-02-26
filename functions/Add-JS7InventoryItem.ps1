function Add-JS7InventoryItem
{
<#
.SYNOPSIS
Add a configuration object such as a workflow from a JSON file to the JOC Cockpit inventory

.DESCRIPTION
This cmdlet reads configuration objects from JSON files and stores them with JOC Cockpit.
Consider that imported objects have to be deployed with the Deploy-JS7DeployableObject and Deploy-JS7ReleasableObject cmdlets.

.PARAMETER Path
Specifies the folder, sub-folder and name of the object to be added, e.g. a workflow path.

.PARAMETER Type
Specifies the object type which is one of:

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

.PARAMETER Item
Specifies the PowerShell object that represents the JSON item to be added. Consider to create a PowerShell object from JSON like this:

   '{ "limit": 1 }' | ConvertFrom-Json

.PARAMETER DocPath
Specifies the path to the documentation that is assigned the object.

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
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Add-JS7InventoryItem -Path /some/directory/sampleLock -Type 'LOCK' -Item ( '{ "limit": 1 }' | ConvertFrom-Json )

On-the-fly adds a resource lock to the invnetory. The JSON document for the resource lock is specified with the -Item parameter.

.EXAMPLE
Add-JS7InventoryItem -Path /some/directory/sampleLock -Type 'LOCK' -Item (Get-Content /tmp/myForkExample.workflow.json -Raw | ConvertFrom-Json -Depth 100)

Reads a resource lock from a file and adds it to the invnetory.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')]
    [string] $Type,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [object] $Item,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $DocPath,
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

        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include directory, sub-directory and object name"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }

    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'valid' -value $False -InputObject $body

        Add-Member -Membertype NoteProperty -Name 'configuration' -value $Item -InputObject $body

        if ( $DocPath )
        {
            Add-Member -Membertype NoteProperty -Name 'docPath' -value $DocPath -InputObject $body
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

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/store' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON )

            if ( !$requestResult.path )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): object added to inventory: $Path"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
