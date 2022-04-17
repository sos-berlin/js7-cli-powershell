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

.PARAMETER AgentId
Optionally specifies the unique identifier of an Agent. More than one Agent identifier can be specified using a comma.

Without the -AgentId and -AgentUrl parameters the report is created for all Agents registered with a Controller.

.PARAMETER AgentUrl
Optionally specifies the URL that points to an Agent. More than one Agent URL can be specified using a comma.

Without the -AgentId and -AgentUrl parameters the report is created for all Agents registered with a Controller.

.PARAMETER ControllerId
Optionally limits reporting results to Agents that are registered with the specified Controller.

.PARAMETER DateFrom
Specifies the date starting from which job executions are reported.

.PARAMETER DateTo
Specifies the date up to which job executions are reported.

.PARAMETER Display
Optionally specifies formatted output to be displayed.

.EXAMPLE
Get-JS7AgentReport -Display -DateFrom 2020-01-01

Displays reporting information about job executions with any Agents since first of January 2020.

.EXAMPLE
Get-JS7AgentReport -AgentUrl http://host-a:4445,http://host-b:4445 -Display

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
    [string[]] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [Uri[]] $AgentUrl,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [DateTime] $DateFrom = (Get-Date -Hour 0 -Minute 00 -Second 00).ToUniversalTime(),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo = (Get-Date).ToUniversalTime(),
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Display
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $agentIds = @()
        $agentUrls = @()
    }

    Process
    {
        if ( $AgentId )
        {
            $agentIds += $AgentId
        }

        if ( $AgentUrl )
        {
            $agentUrls += $AgentUrl
        }
    }

    End
    {
        $body = New-Object PSObject

        if ( $agentIds )
        {
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value $agentIds -InputObject $body
        }

        if ( $agentUrls )
        {
            Add-Member -Membertype NoteProperty -Name 'urls' -value $agentUrls -InputObject $body
        }

        if ( $DateFrom )
        {
            Add-Member -Membertype NoteProperty -Name 'dateFrom' -value ( Get-Date (Get-Date $DateFrom).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
        }

        if ( $DateTo )
        {
            Add-Member -Membertype NoteProperty -Name 'dateTo' -value ( Get-Date (Get-Date $DateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
        }

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents/report' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnReport = ( $response.Content | ConvertFrom-Json )
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
