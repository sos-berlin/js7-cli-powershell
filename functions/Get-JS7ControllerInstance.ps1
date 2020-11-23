function Get-JS7ControllerInstance
{
<#
.SYNOPSIS
Returns Controller information from the JOC Cockpit.

.DESCRIPTION
Returns any JobScheduler Controller Cluster members - including standalone instances - that are connected to JOC Cockpit.

.PARAMETER Id
Specifies the ID of a JobScheduler Controller that was used during installation of the product.
If no ID is specified then the first JobScheduler Controller registered with JOC Cockpit will be used.

.PARAMETER Active
This switch specifies that only the active instance of a JobScheduler Controller cluster should be returned.

Without use of this switch active and passive Controller instances in a cluster are returned.

.PARAMETER Passive
This switch specifies that only the passive instance of a JobScheduler Controller cluster should be returned.

Without use of this switch active and passive Controller instances in a cluster are returned.

.OUTPUTS
This cmdlet returns an array of Controller Cluster member objects.

.EXAMPLE
$Controllers = Get-JS7ControllerInstance

Returns the Controller standalone instance or all members in a JS7 cluster.

.EXAMPLE
$Controllers = Get-JS7ControllerInstance -Id some-controllerId

Returns the Controller standalone instance or all members of a JS7 cluster with the specified Controller ID.

.EXAMPLE
$activeController = Get-JobSchedulerControllerInstance -Id some-controller-id -Active

Returns the Controller standalone instance or all members of a JS7 cluster with the specified Controller ID.

.EXAMPLE
$Controllers = Get-JS7ControllerInstance -Active

Return the Controller standalone instance or the active member of a JS7 cluster.

.EXAMPLE
$Controllers = Get-JS7ControllerInstance -Passive

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
