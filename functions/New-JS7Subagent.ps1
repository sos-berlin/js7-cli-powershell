function New-JS7Subagent
{
<#
.SYNOPSIS
Returns an array of Subagent objects

.DESCRIPTION
This cmdlet returns an array of Subagent objects.

Consider that the Subgent identification specified with the -SubagentId parameter cannot be modified
for the lifetime of a Subagent.

.PARAMETER SubagentId
Specifies a unique identifier for the Subagent. The Subagent ID cannot be chaned during the lifetime of a Subagent.

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
The ordering is specified in ascening numbers.

.PARAMETER GenerateSubagentCluster
Optionally specifies if a Subagent Cluster should be created that holds the Subagent as its unique member.
This option is useful if the Subagent Cluster should be assigned directly to jobs that rely on being
executed with the Subagent only.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns an array of Subagent objects.

.EXAMPLE
$subagents = @()
$subagents += New-JS7Subagent -SubagentId subagent_001 -Url https://subagent-2-0-primary:4443

Returns an array of Subagent objects with the specified Subagent ID and URL.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
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
    [switch] $GenerateSubagentCluster
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

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

        if ( $PSCmdlet.ShouldProcess( 'subagents', 'subagent object' ) )
        {
            $subagents += $subagentObj
        }
    }

    End
    {
        $subagents

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
