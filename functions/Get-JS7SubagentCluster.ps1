function Get-JS7SubagentCluster
{
<#
.SYNOPSIS
Returns a number of Subagent Clusters from the JOC Cockpit inventory

.DESCRIPTION
This cmdlet returns a number of Subagent Clusters from the JOC Cockpit inventory.

The following REST Web Service API resources are used:

* /agents/cluster/

.PARAMETER AgentId
Specifies the unique identifier of the Cluster Agent.

.PARAMETER SubagentClusterId
Optionally specifies a unique identifier for the Subagent Cluster.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller to which the order is added.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Get-JS7SubagentCluster -AgentId 'agent_001'

Returns the Subagent Clusters configured for the indicated Agent Cluster.

.EXAMPLE
Get-JS7SubagentCluster -AgentId 'agent_001' -SubagentClusterId 'subagent_cluster_001'

Returns a Subagent Cluster.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $SubagentClusterId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $agentIds = @()
        $subagentClusterIds = @()
    }

    Process
    {
        if ( $AgentId )
        {
            $agentIds += $AgentId
        }

        if ( $SubagentClusterId )
        {
            $SubagentClusterIds += $SubagentClusterId
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

        if ( $agentIds.count )
        {
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value $agentIds -InputObject $body
        }

        if ( $subagentClusterIds.count )
        {
            Add-Member -Membertype NoteProperty -Name 'subagentClusterIds' -value $subagentClusterIds -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents/cluster' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $requestResult.subagentClusters
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($SubagentClusterId.count) Subagent Clusters found"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
