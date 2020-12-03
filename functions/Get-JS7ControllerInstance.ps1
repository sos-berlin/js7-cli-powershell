function Get-JS7ControllerInstance
{
<#
.SYNOPSIS
Returns information about a JS7 Controller instance from JOC Cockpit

.DESCRIPTION
Returns any JS7 standalone Controller instace or JS7 Controller Cluster members that are connected to JOC Cockpit.

.PARAMETER Id
Specifies the ID of a JS7 Controller that was specified during installation of the product.
If no ID is specified then the first JS7 Controller registered with JOC Cockpit will be used.

.PARAMETER Active
This switch specifies that only the active instance of a JS7 Controller cluster should be returned.

Without use of this switch active and passive Controller instances of a cluster are returned.

.PARAMETER Passive
This switch specifies that only the passive instance of a JS7 Controller cluster should be returned.

Without use of this switch active and passive Controller instances of a cluster are returned.

.OUTPUTS
This cmdlet returns an array of Controller Cluster member objects.

.EXAMPLE
$controllers = Get-JS7ControllerInstance

Returns the Controller standalone instance or all members of a JS7 cluster.

.EXAMPLE
$controllers = Get-JS7ControllerInstance -Id some-controllerId

Returns the Controller standalone instance or all members of a JS7 Controller cluster with the specified Controller ID.

.EXAMPLE
$activeController = Get-JS7ControllerInstance -Id some-controller-id -Active

Returns the Controller standalone instance or the active member of a JS7 cluster with the specified Controller ID.

.EXAMPLE
$activeController = Get-JS7ControllerInstance -Active

Return the Controller standalone instance or the active member of a JS7 cluster.

.EXAMPLE
$passiveController = Get-JS7ControllerInstance -Passive

Return the Controller standalone instance or the passive member of a JS7 cluster.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Id,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Active,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Passive
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Id=$Id"

        if ( !$Id )
        {
            $Id = $script:jsWebService.ControllerId
        }

        if ( !$Active -and !$Passive )
        {
            $Active = $true
            $Passive = $true
        }

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $Id -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/controller' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $volatileStatus = ( $response.Content | ConvertFrom-JSON ).controller
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/controllers/p' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $clusterStatus = ( $response.Content | ConvertFrom-JSON ).Controllers
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    
 
        $returnControllerCluster = New-Object PSObject

        foreach( $clusterNodeInstance in $clusterStatus )
        {
            if ( $clusterNodeInstance.Url -eq $volatileStatus.Url )
            {
                if ( $Active -and ( !$volatileStatus.clusterNodeState -or $volatileStatus.clusterNodeState._text -eq 'active' ) )
                {
                    Add-Member -Membertype NoteProperty -Name 'Active' -value $clusterNodeInstance -InputObject $returnControllerCluster
                } elseif ( $Passive ) {
                    Add-Member -Membertype NoteProperty -Name 'Passive' -value $clusterNodeInstance -InputObject $returnControllerCluster
                }
            } else {
                if ( $Active -and $volatileStatus.clusterNodeState._text -eq 'active' )
                {
                    Add-Member -Membertype NoteProperty -Name 'Passive' -value $clusterNodeInstance -InputObject $returnControllerCluster
                } elseif ( $Passive ) {
                    Add-Member -Membertype NoteProperty -Name 'Active' -value $clusterNodeInstance -InputObject $returnControllerCluster
                }
            }
        }
        
        $returnControllerCluster
    }

    End
    {
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
