function Get-JS7AgentInstance
{
<#
.SYNOPSIS
Returns Agent instances assigned the JS7 Controller.

.DESCRIPTION
Returns a list of Agent instances that are assigned a JS7 Controller.

.PARAMETER Enabled
Specifies to return only enabled Agents.

.OUTPUTS
This cmdlet returns an array of Agent instance objects.

.EXAMPLE
$agents = Get-JS7AgentInstance

Returns all Agent instances for the current Controller.

.EXAMPLE
$agents = Get-JS7AgentInstance -Enabled

Returns all enabled Agent instances for the current Controller.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Enabled
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
    }
        
    Process
    {
    }
    
    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'onlyEnabledAgents' -value ($Enabled -eq $True) -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents/p' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $returnAgents = ( $response.Content | ConvertFrom-JSON ).agents
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    

        $returnAgents
        
        if ( $returnAgents.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnAgents.count) Agents found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Agents found"
        }
        
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session        
    }
}
