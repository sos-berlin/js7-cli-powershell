function Get-JS7AgentReport
{
<#
.SYNOPSIS
Returns reporting information about job executions from a JS7 Agent

.DESCRIPTION
Reporting information about job executions is returned from a JS7 Agent.

Reporting information includes e.g. the number of successfully executed tasks with an Agent.

The following REST Web Service API resources are used:

* /agents/report

.PARAMETER Agents
Specifies an array of URLs that point to Agents. This is useful if specific Agents
should be checked. Without this parameter all Agents registered with a Controller will be checked.

.PARAMETER DateFrom
Specifies the date starting from which job executions are reported.

.PARAMETER DateTo
Specifies the date up to which job executions are reported.

.PARAMETER Display
Optionally specifies formatted output to be displayed.

.EXAMPLE
Get-JS7AgentReport -Display -DateFrom 2020-01-01

Displays reporting information about job executions sind first of January 2020.

.EXAMPLE
Get-JS7AgentReport -Agents http://host-a:4445,http://host-b:4445 -Display

Returns reporting information about job executions with the indicated Agents for today. Formatted output is displayed.

.EXAMPLE
$report = Get-JS7AgentReport -DateFrom 2020-04-01 -DateTo 2020-06-30

Returns an object that includes reporting information for the second quarter 2020.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [Uri[]] $Agents,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date -Hour 0 -Minute 00 -Second 00).ToUniversalTime(),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo = (Get-Date).ToUniversalTime(),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Display
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $allAgents = @()
    }

    Process
    {
        foreach( $agent in $Agents )
        {
            $allAgents += $agent
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $allAgents )
        {
            Add-Member -Membertype NoteProperty -Name 'agents' -value $allAgents -InputObject $body
        }

        if ( $DateFrom )
        {
            Add-Member -Membertype NoteProperty -Name 'dateFrom' -value ( Get-Date (Get-Date $DateFrom).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
        }

        if ( $DateTo )
        {
            Add-Member -Membertype NoteProperty -Name 'dateTo' -value ( Get-Date (Get-Date $DateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents/report' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnReport = ( $response.Content | ConvertFrom-JSON )
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Display -and $returnReport.agents )
        {
            $totalNumOfJobs = 0
            $totalnumOfSuccessfulTasks = 0

            foreach( $reportAgent in $returnReport.agents )
            {
                $totalNumOfJobs += $reportAgent.numOfJobs
                $totalNumOfSuccessfulTasks += $reportAgent.numOfSuccessfulTasks
                $output = "
________________________________________________________________________
............ Agent URL: $($reportAgent.url)
............. Agent ID: $($reportAgent.agentId)
........ Controller ID: $($reportAgent.controllerId)
................. jobs: $($reportAgent.numOfJobs)
..... successful tasks: $($reportAgent.numOfSuccessfulTasks)
________________________________________________________________________
                    "
                Write-Output $output
            }

            $output = "
________________________________________________________________________
........... Total Jobs:  $($totalNumOfJobs)
. Total Job Executions:  $($totalNumOfSuccessfulTasks)
________________________________________________________________________
                    "
            Write-Output $output
        } elseif ( !$Display ) {
            return $returnReport
        }

        if ( $returnReport.agents )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnReport.agents.count) Agents found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Agents found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
