function Remove-JS7InventoryItem
{
<#
.SYNOPSIS
Removes objects such as workflows, schedules etc. from the JOC Cockpit inventory.

.DESCRIPTION
This cmdlet removes objects such as a workflows, schedules etc. from the JOC Cockpit inventory.

Consider to commit removals by deploying or releasing the object,
see the Publish-JS7DeployableItem and  Publish-JS7ReleasableItem cmdlets.

.PARAMETER Path
Specifies the folder and sub-folders of the object.

.PARAMETER Type
Specifies the object type which is one of:

* WORKFLOW
* JOBCLASS
* LOCK
* JUNCTION
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* SCHEDULE

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
This cmdlet accepts pipelined objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7InventoryItem -Path /some_folder/sampleWorkflow -Type 'WORKFLOW'

Removes the indicated worfklow from the JOC Cockpit inventory.

.LINK
about_js7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBCLASS','LOCK','JUNCTION','FILEORDERSOURCE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')]
    [string] $Type,
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

        $removableObjects = @()
    }

    Process
    {
        if ( $Type -ne 'FOLDER' -and $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }

        if ( $Path.endsWith('/') )
        {
            $Path = $Path.Substring( 0, $Path.Length-1 )
        }

        $removableObj = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $removableObj
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $removableObj

        $removableObjects += $removableObj
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'objects' -value $removableObjects -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( $Path, '/inventory/remove' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/remove' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): object removed: $Path"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
