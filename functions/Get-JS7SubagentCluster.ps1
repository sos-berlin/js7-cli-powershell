function Get-JS7SubagentCluster
{
<#
.SYNOPSIS
Returns a Subagent Cluster from the JOC Cockpit inventory

.DESCRIPTION
This cmdlet returns a Subagent Cluster from the JOC Cockpit inventory.

The following REST Web Service API resources are used:

* /agents/cluster/

.PARAMETER AgentId
Specifies the unique identifier of the Cluster Agent.

.PARAMETER SubagentClusterId
Specifies a unique identifier for the Subagent Cluster. This identifier cannot be modified during the lifetime of a Subagent Cluster.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Get-JS7SubagentCluster -AgentId 'agent_001' -SubagentClusterId 'subagent_cluster_001'

Returns a Subagent Cluster.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $SubagentClusterId
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
        $agentIds += $AgentId
        $SubagentClusterIds += $SubagentClusterId
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'agentIds' -value $agentIds -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'subagentClusterIds' -value $subagentClusterIds -InputObject $body

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
