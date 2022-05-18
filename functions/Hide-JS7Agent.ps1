function Hide-JS7Agent
{
<#
.SYNOPSIS
Hides a Standalone Agent in JOC Cockpit

.DESCRIPTION
This cmdlet hides a Standalone Agent. A hidden Standalone Agent cannot be assigned a job in a workflow.
In addition a hidden Standalone Agent is not considerd with the Agent Component Status and
Agent Health Status widgets in the Dashboard view.

The following REST Web Service API resources are used:

* /agents
* /agents/inventory/store

.PARAMETER AgentId
Specifies the unique identifier of the Standalone Agent.

.PARAMETER ControllerId
Specifies the identification of the Controller to which the Standalone Agent is dedicated.

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
Hide-JS7Agent -AgentId 'agent_001'

Hides the indicated Standalone Agent.

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
        $agents = @()
    }

    Process
    {
        $agentIds += $AgentId
    }

    End
    {
        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'agentIds' -value $agentIds -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json ).agents

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $agents = $requestResult
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        foreach( $agent in $agents )
        {
            $body = New-Object PSObject

            if ( $ControllerId )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            }

            $agentObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'agentId' -value $agent.AgentId -InputObject $agentObj
            Add-Member -Membertype NoteProperty -Name 'agentName' -value $agent.AgentName -InputObject $agentObj

            if ( $agent.AgentNameAliases )
            {
                Add-Member -Membertype NoteProperty -Name 'agentNameAliases' -value $agent.AgentNameAliases -InputObject $agentObj
            }

            Add-Member -Membertype NoteProperty -Name 'url' -value $agent.Url -InputObject $agentObj
            Add-Member -Membertype NoteProperty -Name 'isClusterWatcher' -value $agent.isClusterWatcher -InputObject $agentObj
            Add-Member -Membertype NoteProperty -Name 'disabled' -value $agent.disabled -InputObject $agentObj
            Add-Member -Membertype NoteProperty -Name 'hidden' -value $True -InputObject $agentObj

            Add-Member -Membertype NoteProperty -Name 'agents' -value @( $agentObj ) -InputObject $body

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

            if ( $PSCmdlet.ShouldProcess( 'agents', '/agents/inventory/store' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/agents/inventory/store' -Body $requestBody

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

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($agentIds.count) Agents hidden"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
