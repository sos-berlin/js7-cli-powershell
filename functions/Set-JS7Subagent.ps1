function Set-JS7Subagent
{
<#
.SYNOPSIS
Stores a Subagent to a Cluster Agent

.DESCRIPTION
This cmdlet stores a Subagent to a Cluster Agent.

Consider that the Subagent identification specified with the -SubagentId parameter cannot be modified
for the lifetime of a Subagent.

The following REST Web Service API resources are used:

* /agents/inventory/cluster/subagents/store

.PARAMETER AgentId
Specifies a unique identifier of the Cluster Agent. The Subagent will be assigned the given Cluster Agent.

.PARAMETER SubagentId
Specifies a unique identifier for the Subagent. The Subagent ID cannot be changed during the lifetime of a Subagent.

.PARAMETER Url
Specifies the URL for which the Subagent is available. A URL includes the protocol (http, https), hostname and port
for which an Agent is operated.

.PARAMETER Title
Optionally specifies a title for the Subagent that can later on be used for searching.

.PARAMETER DirectorType
Specifies if the Subagent acts as a Director Agent or Subagent only. The following values can be used:

* NO_DIRECTOR: the Agent acts as a Subagent only
* PRIMARY_DIRECTOR: the Agent acts as a Primary Director Agent and includes a Subagent
* SECONDARY_DIRECTOR: the Agent acts as a Secondary Director Agent and includes a Subagent

.PARAMETER Ordering
Optionally specifies the sequence in which Subagents are returned and displayed by JOC Cockpit.
The ordering is specified in ascending numbers.

.PARAMETER GenerateSubagentCluster
Optionally specifies if a Subagent Cluster should be created that holds the Subagent as its unique member.
This option is useful if the Subagent Cluster should be assigned directly to jobs that rely on being
executed with the Subagent only.

.PARAMETER ControllerId
Specifies the identification of the Controller to which Agents are added.

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
Set-JS7Subagent -AgentId 'agent_001' -SubagentId 'subagent_001' -Url https://subagent-2-0-primary:4443 -ControllerId 'testsuite'

Stores a Subagent with the specified attributes to the given Cluster Agent and Controller.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SubagentId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Title,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('NO_DIRECTOR','PRIMARY_DIRECTOR','SECONDARY_DIRECTOR',IgnoreCase = $False)]
    [string] $DirectorType = 'NO_DIRECTOR',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Ordering,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $GenerateSubagentCluster,
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

        $subagents = @()
    }

    Process
    {
        $subagentObj = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'subagentId' -value $SubagentId -InputObject $subagentObj
        Add-Member -Membertype NoteProperty -Name 'url' -value $Url -InputObject $subagentObj

        if ( $Title )
        {
            Add-Member -Membertype NoteProperty -Name 'title' -value $Title -InputObject $subagentObj
        }

        if ( $Ordering )
        {
            Add-Member -Membertype NoteProperty -Name 'ordering' -value $Ordering -InputObject $subagentObj
        }

        if ( $DirectorType )
        {
            Add-Member -Membertype NoteProperty -Name 'isDirector' -value $DirectorType -InputObject $subagentObj
        }

        Add-Member -Membertype NoteProperty -Name 'withGenerateSubagentCluster' -value ($GenerateSubagentCluster -eq $True) -InputObject $subagentObj

        $subagents += $subagentObj
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

        Add-Member -Membertype NoteProperty -Name 'agentId' -value $AgentId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'subagents' -value $subagents -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'agents', '/agents/inventory/cluster/subagents/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/inventory/cluster/subagents/store' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($subagents.count) Subagents stored to inventory Cluster Agent: $AgentId"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
