function Get-JS7Version
{
<#
.SYNOPSIS
Returns the JS7 product versions for JOC Cockpit, Controller and Agents

.DESCRIPTION
The cmdlet returns the version of the JS7 JOC Cockpit, Controller and Agents.

The following REST Web Service API resources are used:

* /joc/versions

.EXAMPLE
Get-JS7Version

Returns the JS7 JOC Cockpit, Controller and Agent versions.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentId
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $ControllerId -InputObject $body
        }

        if ( $AgentId )
        {
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value $AgentId -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/joc/versions' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            ( $response.Content | ConvertFrom-JSON )
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
