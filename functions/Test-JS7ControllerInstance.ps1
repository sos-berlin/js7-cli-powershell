function Test-JS7ControllerInstance
{ 
<#
.SYNOPSIS
Tests the connection to a JS7 Controller instance

.DESCRIPTION
The cmdlets tests the connection between JOC Cockpit and a Controller instance.
A standalone Controller instance or the active or passive member of a Controller cluster can be 
tested to be accessible.

.PARAMETER Url
Specifies the Url of the Controller instance to be tested.

Without use of this parameter and the -Passive parameter  
a standalone Controller instance or the active member of a Controller cluster is checked. 

.PARAMETER Passive
Specifies that the passive member of Controller cluster should be be tested.

Without use of this parameter and the -Url parameter  
a standalone Controller instance or the active member of a Controller cluster is checked. 

.OUTPUTS
This cmdlet returns status information about a Controller.

.EXAMPLE
$result = Test-JS7ControllerInstance

Checks if a standalone Controller instance or the active member of a Controller cluster is accessible.

.EXAMPLE
$result = Test-JS7ControllerInstance -Passive

Checks if the passive member of a Controller cluster is accessible.

.EXAMPLE
$result = Test-JS7ControllerInstance -Url (Get-JS7ControllerInstance -Active).active.url

Checks if the Controller instance from the given URL is accessible.

.LINK
about_js7

#>
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Passive
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
    }

    Process
    {
        if ( !$Url -and !$Passive )
        {
            $Url = (Get-JS7ControllerInstance).Active.Url
        } elseif ( !$Url -and $Passive ) {
            $Url = (Get-JS7ControllerInstance).Passive.Url
        }

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'url' -value $Url -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/controller/test' -Body $requestBody
        
        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON ).controller
            
            if ( !$requestResult.controllerId )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $requestResult
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
