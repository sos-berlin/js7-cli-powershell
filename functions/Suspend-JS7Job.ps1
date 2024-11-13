function Suspend-JS7Job
{
<#
.SYNOPSIS
Suspends one or more jobs at their position in a workflow

.DESCRIPTION
Jobs are suspended from labels that indicate their occurrence in a workflow.
Suspended jobs can be resumed using the Resume-JS7Job cmdlet.

The following REST Web Service API resources are used:

* /workflow/stop

.PARAMETER Path
Specifies the workflow from its name or path in which jobs should be suspended.

.PARAMETER VersionId
A number of versions of a workflow can co-exist when orders are assigned the related workflow version.

The parameter specifies the workflow version to be used. If the parameter is not specified then the latest version is used.

.PARAMETER Labels
Specifies the labels assigned the positions of jobs in the workflow that should be suspended. A job can occur any number of times in a workflow.

.PARAMETER ControllerId
Specifies the identification of the Controller for which jobs in workflows should be suspended.


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
This cmdlet accepts pipelined workflow paths, versions and labels.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Suspend-JS7Job -Path /myFolder/testStandaloneAgents -Labels job1

Suspends the job at the indicated label in the workflow.

.EXAMPLE
Suspend-JS7Job -Path /myFolder/testStandaloneAgents -Labels job1,job2

Suspends the jobs at the indicated labels in the workflow.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('WorkflowPath')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Alias('WorkflowVersionId')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $VersionId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Labels,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
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
    }

    Process
    {
        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

            $workflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $workflow

            if ( $VersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $VersionId -InputObject $workflow
            }

        Add-Member -Membertype NoteProperty -Name 'workflowId' -value $workflow -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'positions' -value $Labels -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'jobs', '/workflow/stop' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/workflow/stop' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json )

                if ( !$requestResult.ok )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($Labels.count) jobs suspended"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}