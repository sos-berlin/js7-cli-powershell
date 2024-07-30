function Remove-JS7Tag
{
<#
.SYNOPSIS
Removes tags from a workflow or from the JS7 inventory

.DESCRIPTION
Removes tags from a workflow or from the JS7 inventory.

The following REST Web Service API resources are used:

* /tags/delete
* /inventory/workflow/tags/store

.PARAMETER WorkflowPath
Optionally specifies the path and/or name of a workflow from which tags should be removed.

If no workflow is specified then tags are removed from all workflows in the JS7 inventory.

.PARAMETER Tag
Specifies one or more tags. If more than one tag is specified, then they must be separated by comma.

If no tag is specified and the -WorkflowPath parameter is used then tags are removed from the workflow.

If no tag is specified and the -WorkflowPath parameter is not used then the -Confirm switch is required to remove all tags from the JS7 inventory.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention,
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This argument is not mandatory, however, JOC Cockpit can be configured
to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined tags.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7Tag -WorkflowPath /sos/reporting/Reporting -Tag Encryption,ScheduledExecution

Removes the indicated tags from the workflow.

.EXAMPLE
Remove-JS7Tag -WorkflowPath /sos/reporting/Reporting

Removes all tags from the indicated workflow.

.EXAMPLE
Remove-JS7Tag -Tag Encryption,ScheduledExecution

Removes the indicated tags from all workflows.

.EXAMPLE
Remove-JS7Tag -Confirm

Removes all tags from all workflows.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Tag,
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

        if ( !$Tag -and !$WorkflowPath -and !$Confirm )
        {
            throw "$($MyInvocation.MyCommand.Name): No tags specified. To delete all tags from a workflow use the -WorkflowPath parameter. To delete all tags from JS7 use the -Confirm parameter."
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $tags = @()
    }

    Process
    {
        $tags += $Tag
    }

    End
    {
        if ( $tags.count )
        {
            $body = New-Object PSObject

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

            if ( $WorkflowPath )
            {
                if ( $tags )
                {
                    $tagBody = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $tagBody

                    [string] $requestBody = $tagBody | ConvertTo-Json -Depth 100
                    $response = Invoke-JS7WebRequest -Path '/inventory/workflow/tags' -Body $requestBody

                    if ( $response.StatusCode -eq 200 )
                    {
                        $requestResult = $response.Content | ConvertFrom-Json
                    } else {
                        throw ( $response | Format-List -Force | Out-String )
                    }

                    if ( $requestResult.tags )
                    {
                        $tags = @( $requestResult.tags | Where-Object { $_ -notin $tags } )
                    }
                }

                Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $body

                if ( $tags )
                {
                    Add-Member -Membertype NoteProperty -Name 'tags' -value $tags -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'tags' -value @() -InputObject $body
                }

                if ( $PSCmdlet.ShouldProcess( 'tags', '/inventory/workflow/tags/store' ) )
                {
                    [string] $requestBody = $body | ConvertTo-Json -Depth 100
                    $response = Invoke-JS7WebRequest -Path '/inventory/workflow/tags/store' -Body $requestBody
                }
            } else {
                if ( !$tags )
                {
                    $response = Invoke-JS7WebRequest -Path '/tags'

                    if ( $response.StatusCode -eq 200 )
                    {
                        $requestResult = $response.Content | ConvertFrom-Json
                    } else {
                        throw ( $response | Format-List -Force | Out-String )
                    }

                    $tags = $requestResult.tags
                }

                if ( $tags )
                {
                    Add-Member -Membertype NoteProperty -Name 'tags' -value $tags -InputObject $body
                }

                if ( $PSCmdlet.ShouldProcess( 'tags', '/tags/delete' ) )
                {
                    [string] $requestBody = $body | ConvertTo-Json -Depth 100
                    $response = Invoke-JS7WebRequest -Path '/tags/delete' -Body $requestBody
                }
            }

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = $response.Content | ConvertFrom-Json

                if ( !$requestResult.ok )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($tags.count) tags removed"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
