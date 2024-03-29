function Reset-JS7Subagent
{
<#
.SYNOPSIS
Resets a Subagent to revoke current orders, workflows etc. and to initialize the Subagent

.DESCRIPTION
This cmdlet resets a Subagent. In a first step any orders, workflows and other deployable objects are revoked from the Subagent.
In a second step the Subagent performs a restart.

In case of a Director Agents in a final step the Controller reconnects to the Agent and deploys any required deployable objects.
In case of a Subagent in a final step the Director Agent connects to the Subagent.

It is recommended to first check the state of orders prior to resetting the Subagent and to complete or to cancel any orders running in a Subagent.

Consider that orders have to be continued if they failed due to reset of a Subagent.

The following REST Web Service API resources are used:

* /agents/inventory/cluster/subagent/reset

.PARAMETER SubagentId
Specifies a unique identifier for a Subagent. This identifier cannot be modified during the lifetime of a Subagent.
In order to modify the Subagent identifier the Subagent has to be removed and added.

.PARAMETER ControllerId
Specifies the identification of the Controller from which Subagents are removed.

.PARAMETER Force
This switch should be used with care as it kills any tasks running with a Subagent.
In case of a Director Agent this switch revokes any orders and workflows
from the Agent and forces the Agent to drop its journal and to restart.

The purpose of this switch is to seize an Agent that is assigned a different Controller or Cluster Agent or that holds
information in its journal that is no longer applicable, for example if the Agent ID should be modified.

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
Reset-JS7Subagent -SubagentId 'subagent_001'

Resets the indicated Subgent.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SubagentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Force,
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

        Add-Member -Membertype NoteProperty -Name 'subagentId' -value $SubagentId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'force' -value ($Force -eq $True) -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'agents', '/agents/inventory/cluster/subagent/reset' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/inventory/cluster/subagent/reset' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): Agent reset: $AgentId"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
