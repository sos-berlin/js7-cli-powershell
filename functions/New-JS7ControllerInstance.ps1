function New-JS7ControllerInstance
{
<#
.SYNOPSIS
Creates a new JS7 Controller instance PowerShell object for use with other cmdlets.

.DESCRIPTION
The cmdlets is used to create a PowerShell object for a new Controller instance
that is added with the Set-JS7Controller cmdlet.

.PARAMETER Url
Specifies the Url of the Controller instance that should be added. The Url is specified
for use by JOC Cockpit.

.PARAMETER ClusterUrl
Specifies the URL by which this Controller can be found from some other cluster member.

Typically this is the same as the -Url parameter. However, depending on network zones
and use of proxies the Controller ID might be accesssible from a different Url in the cluster.

If this parameter is not specified then the value of the -Url parameter is used for the cluster Url.

.PARAMETER Title
Specifies a title for the Controller instance that becomes visible with the JOC Cockpit dashboard.

.OUTPUTS
This cmdlet returns a PowerShell custom object for a Controller instance.

.EXAMPLE
$instance = New-JS7ControllerInstance -Url https://controller-primary.sos:4443 -Title 'PRIMARY CONTROLLER'

Returns a PowerShell object for a new Controller instance.
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
