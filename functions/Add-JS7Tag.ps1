function Add-JS7Tag
{
<#
.SYNOPSIS
Adds tags to the JS7 inventory and optionally assigns them a workflow

.DESCRIPTION
Adds tags to the JS7 inventory and optionally assigns them a workflow.

The following REST Web Service API resources are used:

* /tags/add
* /inventory/workflow/tags/store

.PARAMETER WorkflowPath
Optionally specifies the path and/or name of a workflow to which tags should be added.

If no workflow is specified then tags are added to the JS7 inventory, but are not assigned a workflow.

.PARAMETER Tag
Specifies one or more tags. If more than one tag is specified, then they must be separated by comma.

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
Add-JS7Tag -WorkflowPath /sos/reporting/Reporting -Tag Encryption,ScheduledExecution

Adds the indicated tags to the workflow.

.EXAMPLE
Add-JS7Tag -Tag Encryption,ScheduledExecution

Adds the indicated tags to the JS7 inventory.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
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
                    $tags = @( $tags | Where-Object { $_ -notin $requestResult.tags } )
                    $tags += $requestResult.tags
                }

                Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'tags' -value $tags -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/workflow/tags/store' -Body $requestBody
            } else {
                Add-Member -Membertype NoteProperty -Name 'tags' -value $tags -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/tags/add' -Body $requestBody
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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($tags.count) tags added"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
