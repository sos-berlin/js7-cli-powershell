function Get-JS7AgentStatus
{
<#
.SYNOPSIS
Return summary information for JS7 Agents assigned the current Controller.

.DESCRIPTION
Summary information is returned for JS7 Agents that are assigned the current Controller.

* Summary information includes e.g. the start date and JS7 Agent release.

This cmdlet can be used to check if an Agent is available.

.PARAMETER AgentId
Optionally specifies the unique identifier of an Agent for which informaiton is retrieved.

Without this parameter any Agents assigned the current Controller are returned.

.PARAMETER Coupled
Specifies to return information about Agents only that are coupled with a Controller.

.PARAMETER Decoupled
Specifies to return information about Agents only that are decoupled from a Controller.
Typically this indicates either an early stage before coupling occurs or an error status.

.PARAMETER CouplingFailed
Specifies to return information about Agents only that could not be successfully coupled with a Controller.
This indicates an error status.

.PARAMETER Enabled
Specifies to return information about enabled Agents only. 

.PARAMETER Compact
Specifies to return a smaller set of information items about Agents.

.PARAMETER Display
Optionally specifies formatted output to be displayed.

.EXAMPLE
Get-JS7AgentStatus -Display

Displays summary information about all JS7 Agents configured for the current Controller.

.EXAMPLE
Get-JS7AgentStatus -Agent agent_001 -Display

Returns summary information about the Agent with ID "agent_001". Formatted output is displayed.

.EXAMPLE
$status = Get-JS7AgentStatus -Decoupled -CouplingFailed

Returns summary information about Agents that currently are not coupled with a Controller.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Coupled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Decoupled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $CouplingFailed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Enabled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Compact,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Display
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
        
        $agentIds = @()
        $states = @()
    }

    Process
    {
        $agentIds += $AgentId
        
        if ( $Coupled )
        {
            $states += 'COUPLED'
        }

        if ( $Decoupled )
        {
            $states += 'DECOUPLED'
        }

        if ( $CouplingFailed )
        {
            $states += 'COUPLINGFAILED'
        }
    }
    
    End
    {    
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $agentIds )
        {
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value $agentIds -InputObject $body
        }
        
        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'onlyEnabledAgents' -value ($Enabled -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'compact' -value ($Compact -eq $True) -InputObject $body


        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $volatileStatus = ( $response.Content | ConvertFrom-JSON ).agents
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

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
