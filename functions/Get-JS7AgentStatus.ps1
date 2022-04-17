function Get-JS7AgentStatus
{
<#
.SYNOPSIS
Returns summary information for JS7 Agents assigned the current Controller

.DESCRIPTION
Summary information is returned for JS7 Agents that are assigned the current Controller.

* Summary information includes e.g. the start date and status of an Agent.

This cmdlet can be used to check if an Agent is available.

The following REST Web Service API resources are used:

* /agents

.PARAMETER AgentId
Optionally specifies the unique identifier of an Agent for which informaiton is retrieved.

Without this parameter any Agents assigned the current Controller are returned.

.PARAMETER Coupled
Specifies to return information about Agents only that are coupled with a Controller.

.PARAMETER CouplingFailed
Specifies to return information about Agents only that could not be successfully coupled with a Controller.
This indicates an error state.

.PARAMETER Reset
Specifies to return information about Agents that did perform a reset operation.
This indicates a volatile state that later on is replaced by a coupling state.

.PARAMETER Resetting
Specifies to return information about Agents that are in process of performing a reset.
During a reset operation the Agent drops its journal and restarts.
This indicates a volatile state, that later on is replaced by a coupling state.

.PARAMETER Shutdown
Specifies to return information about Agents only that in process of shutting down.
This indicates that respective Agents are about to terminate.

.PARAMETER Unknown
Specifies to return information about Agents only for which the status is unknown.
An unknown status indicates that no connection can be established to the respective Agent.

.PARAMETER NotHidden
Specifies to return information about visible Agents only.

.PARAMETER Compact
Specifies to return a smaller set of information items about Agents.

.PARAMETER Display
Optionally specifies formatted output to be displayed.

.EXAMPLE
Get-JS7AgentStatus -Display

Displays summary information about all JS7 Agents configured for the current Controller.

.EXAMPLE
Get-JS7AgentStatus -AgentId 'agent_001' -Display

Returns summary information about the Agent with ID "agent_001". Formatted output is displayed.

.EXAMPLE
$status = Get-JS7AgentStatus -Decoupled -CouplingFailed

Returns summary information about Agents that currently are not coupled with a Controller.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Coupled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $CouplingFailed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Reset,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Resetting,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Shutdown,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Unknown,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $NotHidden,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Compact,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Display
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $agentIds = @()
        $states = @()
    }

    Process
    {
        if ( $AgentId )
        {
            $agentIds += $AgentId
        }

        if ( $Coupled )
        {
            $states += 'COUPLED'
        }

        if ( $CouplingFailed )
        {
            $states += 'COUPLINGFAILED'
        }

        if ( $Reset )
        {
            $states += 'RESET'
        }

        if ( $Resetting )
        {
            $states += 'RESETTING'
        }

        if ( $Shutdown )
        {
            $states += 'SHUTDOWN'
        }

        if ( $Unknown )
        {
            $states += 'UNKNOWN'
        }
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

        if ( $agentIds )
        {
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value $agentIds -InputObject $body
        }

        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'onlyVisibleAgents' -value ($NotHidden -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'compact' -value ($Compact -eq $True) -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $volatileStatus = ( $response.Content | ConvertFrom-Json ).agents
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( !$Display )
        {
            $volatileStatus
        } else {
            foreach( $agentStatus in $volatileStatus )
            {
                $output = "
________________________________________________________________________
JobScheduler Agent URL: $($agentStatus.url)
................... ID: $($agentStatus.agentId)
................. name: $($agentStatus.agentName)
................ state: $($agentStatus.state._text)
........ error message: $($agentStatus.errorMessage)
........ running tasks: $($agentStatus.runningTasks)
........ Controller ID: $($agentStatus.controllerId)
... is cluster watcher: $($agentStatus.isClusterWatcher)
________________________________________________________________________
                    "
                Write-Output $output
            }
        }

        if ( $volatileStatus.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($volatileStatus.count) Agents found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Agents found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
