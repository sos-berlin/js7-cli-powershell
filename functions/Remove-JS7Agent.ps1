function Remove-JS7Agent
{
<#
.SYNOPSIS
Removes a Standalone Agent or Cluster Agent from a Controller and from the JOC Cockpit inventory

.DESCRIPTION
This cmdlet removes a Standalone Agent or Cluster Agent from its Controller and from the JOC Cockpit inventory.

It is required to complete or to cancel any orders attached the Agent prior to removing the Agent.

The following REST Web Service API resources are used:

* /agent/delete

.PARAMETER AgentId
Specifies the unique identifier of the Standaone Agent or Cluster Agent.

More than one Agent can be specified by separating Agent IDs by a comma.

.PARAMETER ControllerId
Specifies the identification of the Controller from which the Standalone Agent or Cluster Agent is removed.

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
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7Agent -AgentId 'agent_001' -ControllerId 'testsuite'

Removes the indicated Agent from the given Controller.

.EXAMPLE
Remove-JS7Agent -AgentId 'agent_001','agent_002' -ControllerId 'testsuite'

Removes the indicated Agents from the given Controller.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentId,
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

        $agentIds = @()
    }

    Process
    {
        $agentIds += $AgentId
    }

    End
    {
        foreach( $agentItemId in $agentIds )
        {
            $body = New-Object PSObject

            if ( $ControllerId )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            }

            Add-Member -Membertype NoteProperty -Name 'agentId' -value $agentItemId -InputObject $body

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

            if ( $PSCmdlet.ShouldProcess( 'agents', '/agent/delete' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/agent/delete' -Body $requestBody

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

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): Agent removed: $agentItemId"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
