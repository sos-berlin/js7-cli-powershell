function Test-JS7ControllerInstance
{
<#
.SYNOPSIS
Tests the connection to a JS7 Controller instance

.DESCRIPTION
The cmdlets tests the connection between JOC Cockpit and a Controller instance.
A standalone Controller instance or the active or standby member of a Controller cluster can be
tested to be accessible.

The following REST Web Service API resources are used:

* /controller/test

.PARAMETER Url
Specifies the Url of the Controller instance to be tested.

Without use of this parameter and the -StandBy parameter
a standalone Controller instance or the active member of a Controller cluster is checked.

.PARAMETER StandBy
Specifies that the standby member of Controller cluster should be be tested.
The alias parameter name -Passive can be used.

Without use of this parameter and the -Url parameter
a standalone Controller instance or the active member of a Controller cluster is checked.

.OUTPUTS
This cmdlet returns status information about a Controller.

.EXAMPLE
$result = Test-JS7ControllerInstance

Checks if a standalone Controller instance or the active member of a Controller cluster is accessible.

.EXAMPLE
$result = Test-JS7ControllerInstance -StandBy

Checks if the standby member of a Controller cluster is accessible.

.EXAMPLE
$result = Test-JS7ControllerInstance -Url (Get-JS7ControllerInstance -Active).active.url

Checks if the Controller instance from the given URL is accessible.

.LINK
about_JS7

#>
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Alias('Passive')]
    [switch] $StandBy
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        if ( !$Url -and !$StandBy )
        {
            $Url = (Get-JS7ControllerInstance).Active.Url
        } elseif ( !$Url -and $StandBy ) {
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
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
