function Set-JS7ClusterAgent
{
<#
.SYNOPSIS
Store a Cluster Agent to the JOC Cockpit inventory

.DESCRIPTION
This cmdlet stores a Cluster Agent to the JOC Cockpit inventory.

Consider that the Cluster Agent identification specified with the -AgentId parameter cannot be modified
for the lifetime of a Cluster Agent.

The following REST Web Service API resources are used:

* /agents/inventory/cluster/store

.PARAMETER AgentId
Specifies a unique identifier for a Cluster Agent. This identifier cannot be modified during the lifetime of a Cluster Agent.
In order to modify the Cluster Agent identifier the Cluster Agent has to be removed and added.

.PARAMETER AgentName
The name of a Cluster Agent is used for example in job assignments of a workflow. During deployment of workflows the Agent Name
is replaced by the respective Agent ID.

Should deployments of the same workflows be performed to a number of Controllers then for each Controller
the same Agent Name has to be configured (pointing to a different Agent ID).

.PARAMETER Url
Specifies the URL for which the Cluster Agent is available. A URL includes the protocol (http, https), hostname and port
for which a Cluster Agent is operated.

.PARAMETER AgentAlias
Optionally specifies a number of alias names for a Cluster Agent that are separated by a comma.
An alias name is an alternative name for the same Cluster Agent that can be used when assigning Agents to jobs.

.PARAMETER Subagents
Optionally specifies an array of Subagents objects that can be created like this:

$subagents = @()
$subagents += New-JS7Subagent -SubagentId subagent_001 -Url https://subagent-2-0-primary:4443
$subagents += New-JS7Subagent -SubagentId subagent_002 -Url https://subagent-2-0-secondary:4443

.PARAMETER ControllerId
Specifies the identification of the Controller to which Cluster Agents are dedicated.

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
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
$subagents = @()
$subagents += New-JS7Subagent -SubagentId subagent_001 -Url https://subagent-2-0-primary:4443
$subagents += New-JS7Subagent -SubagentId subagent_002 -Url https://subagent-2-0-secondary:4443
Set-JS7ClusterAgent -AgentId agent_001 -AgentName clusterAgent -Url https://agent-2-0-cluster:4443 -Subagents $subagents -ControllerId 'testsuite'

Stores a Cluster Agent with the specified attributes and Subagents to the JOC Cockpit inventory.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentName,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Title,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentAlias,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [object[]] $Subagents,
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

        $agents = @()
    }

    Process
    {
        $agentObj = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'agentId' -value $AgentId -InputObject $agentObj
        Add-Member -Membertype NoteProperty -Name 'agentName' -value $AgentName -InputObject $agentObj
        Add-Member -Membertype NoteProperty -Name 'url' -value $Url -InputObject $agentObj

        if ( $Title )
        {
            Add-Member -Membertype NoteProperty -Name 'title' -value $Title -InputObject $agentObj
        }

        if ( $AgentAlias )
        {
            Add-Member -Membertype NoteProperty -Name 'agentNameAliases' -value $AgentAlias -InputObject $agentObj
        }

        if ( $Subagents )
        {
            Add-Member -Membertype NoteProperty -Name 'subagents' -value $Subagents -InputObject $agentObj
        }

        $agents += $agentObj
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

        Add-Member -Membertype NoteProperty -Name 'clusterAgents' -value $agents -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'agents', '/agents/inventory/cluster/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/inventory/cluster/store' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($agents.count) Cluster Agents stored to inventory"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
