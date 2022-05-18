function Set-JS7SubagentCluster
{
<#
.SYNOPSIS
Stores a Subagent Cluster to the JOC Cockpit inventory

.DESCRIPTION
This cmdlet stores a Subagent Cluster to the JOC Cockpit inventory that later on can be deployed to a Controller.

Consider that the Subagent Cluster identification specified with the -SubagentClusterId parameter cannot be modified
for the lifetime of a Subagent Cluster.

The following REST Web Service API resources are used:

* /agents/cluster/store

.PARAMETER AgentId
Specifies the unique identifier of the Cluster Agent.

.PARAMETER SubagentClusterId
Specifies a unique identifier for the Subagent Cluster. This identifier cannot be modified during the lifetime of a Subagent Cluster.
In order to modify the Subagent Cluster identifier the Subagent Cluster has to be removed and added.

.PARAMETER Title
Optionally specifies a title for the Subagent Cluster that can be searched for.

.PARAMETER SubagentId
Specifies the unique identifier of one or more Subagents that make up a cluster.
A number of Subagent IDs can be specified separated by a comma.

.PARAMETER Priority
Optionally specifies the scheduling mode in the Subagent Cluster:

* If all Subagents use the same priority then this results in an active-active cluster.
* If Subagents use different priorities then this results in an active-passive cluster.

If more than one Subagent is specified with the -SubagentId parameter then accordingly priorities have to be specified separated by a comma.

By default the same priority is applied to all Subagents which results in an active-active cluster.

.PARAMETER Type
Optionally specifies the cluster type:

* ACTIVE: Subagents in the cluster are used in round-robin scheduling mode
* PASSIVE: Subagents in the cluster use fixed-priority scheduling mode

This parameter cannot be used if the -Priority parameter is in place: specifying the cluster -Type causes the cmdlet to determine priorities of Subagents in the Cluster.
Alternatively the -Priority parameter allows to specify the priority per Subagent in the cluster.

.PARAMETER Add
Optionally specifies that the Subagents specified with the -SubagentId parameter are added to an existing Subagent Cluster.

.PARAMETER Remove
Optionally specifies that the Subagents specified with the -SubagentId parameter are removed from an existing Subagent Cluster.

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
Set-JS7SubagentCluster -AgentId 'agent_001' -SubagentClusterId 'subagent_cluster_001' -SubagentId 'subagent_001','subagent_002' -Priority 1,1

Stores a Subagent Cluster with two Subagents as an active-active cluster.

.EXAMPLE
Set-JS7SubagentCluster -AgentId 'agent_001' -SubagentClusterId 'subagent_cluster_001' -SubagentId 'subagent_001','subagent_002' -Priority 2,1

Stores a Subagent Cluster with two Subagents as an active-passive cluster.

.EXAMPLE
Set-JS7SubagentCluster -AgentId 'agent_001' -SubagentClusterId 'subagent_cluster_001' -SubagentId 'subagent_003' -Add

Adds the indicated Subagent to the existing Subagent Cluster.

.EXAMPLE
Set-JS7SubagentCluster -AgentId 'agent_001' -SubagentClusterId 'subagent_cluster_001' -SubagentId 'subagent_003' -Remove

Removes the indicated Subagent from the existing Subagent Cluster.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SubagentClusterId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Title,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $SubagentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int[]] $Priority,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ACTIVE','PASSIVE')]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Add,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Remove,
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

        if ( $Type -and $Priority )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Type and -Priority can be used"
        }

        if ( $Priority -and ( $Add -or $Remove ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Priority and -Add or -Remove can be used"
        }

        if ( $Add -and $Remove )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Add and -Remove can be used"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $subagents = @()
    }

    Process
    {
        if ( !$Type -and !$Priority )
        {
            $Type = 'ACTIVE'
        }

        if ( $Add -or $Remove )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value @( $AgentId ) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'subagentClusterIds' -value @( $SubagentClusterId ) -InputObject $body

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/cluster' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json )

                if ( !$requestResult )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }

                $subagents = $requestResult.subagentClusters.subagentIds

                if ( $Add )
                {
                    for( $i=0; $i -lt $SubagentId.count; $i++ )
                    {
                        $subagentObj = New-Object PSObject
                        Add-Member -Membertype NoteProperty -Name 'subagentId' -value $SubagentId[$i] -InputObject $subagentObj

                        if ( $Type -eq 'ACTIVE' )
                        {
                            Add-Member -Membertype NoteProperty -Name 'priority' -value $subagents[$subagents.count-1].priority -InputObject $subagentObj
                        } else {
                            Add-Member -Membertype NoteProperty -Name 'priority' -value ($subagents[$subagents.count-1].priority -1) -InputObject $subagentObj
                        }

                        $subagents += $subagentObj
                    }
                } elseif ( $Remove ) {
                    $newSubagents = @()

                    for( $i=0; $i -lt $subagents.count; $i++ )
                    {
                        $found = $False

                        for( $j=0; $j -lt $SubagentId.count; $j++ )
                        {
                            if ( $SubagentId[$j] -eq $subagents[$i].subagentId )
                            {
                                $found = $True
                            }
                        }

                        if ( !$found )
                        {
                            $newSubagents += $subagents[$i]
                        }
                    }

                    $subagents = $newSubagents
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            for( $i=0; $i -lt $SubagentId.count; $i++ )
            {
                $subagentObj = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'subagentId' -value $SubagentId[$i] -InputObject $subagentObj

                if ( $Priority )
                {
                    if ( $Priority.count -gt $i )
                    {
                        $subagentPriority = $Priority[$i]
                    } else {
                        $subagentPriority = 1
                    }
                } elseif ( $Type -eq 'ACTIVE' ) {
                    $subagentPriority = 1
                } elseif ( $Type -eq 'PASSIVE' ) {
                    $subagentPriority = ( $SubagentId.count-$i )
                }

                Add-Member -Membertype NoteProperty -Name 'priority' -value $subagentPriority -InputObject $subagentObj
                $subagents += $subagentObj
            }
        }

        $body = New-Object PSObject
        $subagentClusterObj = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'agentId' -value $AgentId -InputObject $subagentClusterObj
        Add-Member -Membertype NoteProperty -Name 'subagentClusterId' -value $SubagentClusterId -InputObject $subagentClusterObj
        Add-Member -Membertype NoteProperty -Name 'subagentIds' -value $subagents -InputObject $subagentClusterObj

        if ( $Title )
        {
            Add-Member -Membertype NoteProperty -Name 'title' -value $Title -InputObject $subagentClusterObj
        }

        Add-Member -Membertype NoteProperty -Name 'subagentClusters' -value @( $subagentClusterObj ) -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'agents', '/agents/cluster/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/agents/cluster/store' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($SubagentId.count) Subagents stored to Subagent Cluster: $SubagentClusterId"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
