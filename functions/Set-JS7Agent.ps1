function Set-JS7Agent
{
<#
.SYNOPSIS
Add an Agent to the JS7 Controller or modify Agent properties

.DESCRIPTION
This cmdlet adds an Agent to a JS7 Controller. A number of Agent properties can be modified.

Consider that the Agent identification specified with the -AgentId parameter cannot be modified
for the lifetime of an Agent.

The following REST Web Service API resources are used:

* /agents/store

.PARAMETER AgentId
Specifies a unique identifier for an Agent. This identifier cannot be modified during the lifetime of an Agent.
In order to modify the Agent identifier the Agent has to be removed and added.

.PARAMETER AgentName
The name of an Agent is used e.g. in job assignments of a workflow. During deployment the Agent Name
is replaced by the respective Agent ID for the Controller to which the workflow is deployed.

Should deployments of the same workflows be performed to a number of Controllers then for each Controller
the same Agent Name has to be configured (pointing to a different Agent ID).

.PARAMETER Url
Specifies the URL for which the Agent is available. A URL includes the protocol (http, https), hostname and port
for which an Agent is operated.

.PARAMETER WatchCluster
A JS7 Controller cluster requires one Agent to be assigned the role of a cluster watcher.
Such an Agent will be considered if the JS7 Controller cluster decides about a fail-over situation with
no network connection being available between primary and secondary JS7 Controller instances.

.PARAMETER Disable
An Agent can be disabled to prevent further use in workflow configurations. Deployed workflows still can
use a disabled Agent.

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
Set-JS7Agent -AgentId agent_001 -AgentName primaryAgent -Url https://agent-2-0-primary:4443 -WatchCluster

Adds an Agent with the specified attributes.

.EXAMPLE
Set-JS7Agent -AgentId agent_002 -AgentName secondaryAgent -Url https://agent-2-0-secondary:4443

Adds an Agent with the specified attributes.

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
    [switch] $WatchCluster,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Disable,
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
        Add-Member -Membertype NoteProperty -Name 'isClusterWatcher' -value ($WatchCluster -eq $True) -InputObject $agentObj
        Add-Member -Membertype NoteProperty -Name 'disabled' -value ($Disable -eq $True) -InputObject $agentObj

        $agents += $agentObj
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'agents' -value $agents -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'agents', '/agents/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/store' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): Agent stored: $AgentId"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
