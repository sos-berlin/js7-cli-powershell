function New-JS7ControllerInstance
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
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $ClusterUrl,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('standalone','primary','backup')] [string] $Role,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [string] $Title
)
    Begin
    {
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $controllerInstance = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'url' -value $Url -InputObject $controllerInstance
        
        if ( $ClusterUrl )
        {
            Add-Member -Membertype NoteProperty -Name 'clusterUrl' -value $ClusterUrl -InputObject $controllerInstance
        }

        Add-Member -Membertype NoteProperty -Name 'role' -value $Role.ToUpper() -InputObject $controllerInstance

        if ( $Title )
        {
            Add-Member -Membertype NoteProperty -Name 'title' -value $Title -InputObject $controllerInstance
        }

        $controllerInstance
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
