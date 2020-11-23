function Get-JS7AgentStatus
{
<#
.SYNOPSIS
Return summary information from a JS7 Agent.

.DESCRIPTION
Summary information is returned from a JS7 Agent.

* Summary information includes e.g. the start date and JS7 Agent release.

This cmdlet can be used to check if an Agent is available.

.PARAMETER Agents
Specifies an array of URLs that point to Agents. This is useful if specific Agents
should be checked. Without this parameter all Agents configured for a Controller will be checked.

.PARAMETER Display
Optionally specifies formatted output to be displayed.

.EXAMPLE
Get-JobSchedulerAgentStatus -Display

Displays summary information about all JS7 Agents configured for the current Controller.

.EXAMPLE
Get-JS7AgentStatus -Agents http://localhost:4445 -Display

Returns summary information about the Agent. Formatted output is displayed.

.EXAMPLE
$status = Get-JS7AgentStatus -Agents http://localhost:4445

Returns a status information object.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [Uri[]] $Agents,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Display
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
        
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
            $objAgents = @()
            foreach( $agent in ( $allAgents | Sort-Object | Get-Unique ) )
            {
                $objAgent = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'agent' -value $agent -InputObject $objAgent
                $objAgents += $objAgent
            }

            Add-Member -Membertype NoteProperty -Name 'agents' -value $objAgents -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $volatileStatus = ( $response.Content | ConvertFrom-JSON ).agents
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents/p' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $permanentStatus = ( $response.Content | ConvertFrom-JSON ).agents
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    
 
        $returnAgents = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'Volatile' -value $volatileStatus -InputObject $returnAgents
        Add-Member -Membertype NoteProperty -Name 'Permanent' -value $permanentStatus -InputObject $returnAgents

        if ( $Display )
        {
            for( $i=0; $i -lt $volatileStatus.count; $i++ )
            {
                $output = "
________________________________________________________________________
JobScheduler Agent URL: $($permanentStatus[$i].url)
................. host: $($permanentStatus[$i].host)
................ state: $($volatileStatus[$i].state._text)
........... started at: $($permanentStatus[$i].startedAt)
........ running tasks: $($volatileStatus[$i].runningTasks)
............. clusters: Agent is member in $($permanentStatus[$i].clusters.count) clusters:"

                foreach( $item in $permanentStatus[$i].clusters )
                {
                    $output += "
.......................: $($item)"
                }
                
                $output += "
.............. version: $($volatileStatus[$i].version)
................... OS: $($permanentStatus[$i].os.name), $($permanentStatus[$i].os.architecture), $($permanentStatus[$i].os.distribution)
________________________________________________________________________
                    "
                Write-Output $output
            }
        } else {
            return $returnAgents
        }

        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
