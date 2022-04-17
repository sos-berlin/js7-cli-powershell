function Get-JS7Agent
{
<#
.SYNOPSIS
Returns a Standalone Agent or Cluster Agent

.DESCRIPTION
This cmdlet returns a Standalone Agent or Cluster Agent.

The following REST Web Service API resources are used:

* /agents
* /agents/inventory

.PARAMETER AgentId
Optionally specifies the unique identifier of the Standalone Agent or Cluster Agent.

More than one Agent can be specified by separating Agent IDs by a comma.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller to which the Standalone Agent or Cluster Agent is dedicated.

.PARAMETER NotHidden
Optionally specifies that only visible Standalone Agents or Cluster Agents should be returned.

.PARAMETER Persistent
Optionally specifies that persistent inventory information only is returned.
Without this switch inventory information is returned directly from the Controller.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
$agents = Get-JS7Agent

Returns all Standalone Agents and Cluster Agents.

.EXAMPLE
$agent = Get-JS7Agent -AgentId 'agent_001'

Returns the indicated Standalone Agent or Cluster Agent.

.EXAMPLE
$agent = Get-JS7Agent -AgentId 'agent_001' -State 'COUPLED'

Returns the indicated Standalone Agent or Cluster Agent with the given state.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('COUPLED','RESETTING','RESET','COUPLINGFAILED','SHUTDOWN',IgnoreCase = $False)]
    [string[]] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NotHidden,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Persistent
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( $State -and $Persistent )
        {
            throw "$($MyInvocation.MyCommand.Name): When limiting results to Agent states then no persistent information can be returned, use -State or -Persistent"
        }

        $agentIds = @()
        $states = @()
    }

    Process
    {
        if ( $AgentId )
        {
            $agentIds += $AgentId
        }

        if ( $State )
        {
            $states += $State
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

        Add-Member -Membertype NoteProperty -Name 'onlyVisibleAgents' -value ($NotHidden -eq $True) -InputObject $body

        if ( $Persistent )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/inventory' -Body $requestBody
        } else {
            if ( $States )
            {
                Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
            }

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents' -Body $requestBody
        }

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json ).agents

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $requestResult
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($agentIds.count) Agents found"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
