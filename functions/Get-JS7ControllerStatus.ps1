function Get-JS7ControllerStatus
{
<#
.SYNOPSIS
Return status information and summary information from a JS7 Controller.

.DESCRIPTION
Status information and summary information are returned from a JS7 Controller.

* Status information includes e.g. the start date and JS7 release.
* Summary information includes e.g. the number of running orders.

.PARAMETER Summary
Specifies that summary infromation about orders and jobs should be returned.

.PARAMETER Display
Specifies that formatted output will be displayed, otherwise a status object will be returned that contain the respective information.

.EXAMPLE
Get-JS7ControllerStatus

Returns status information about the JS7 Controller.

.EXAMPLE
Get-JS7ControllerStatus -Summary -Display

Returns status information and summary information about orders and jobs. Formatted output is displayed.

.EXAMPLE
$status = Get-JS7ControllerStatus -Summary

Returns an object including status information and summary information.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Summary,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Display
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
    }

    Process
    {        
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/controller' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $volatileStatus = ( $response.Content | ConvertFrom-JSON ).controller
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    


        $response = Invoke-JS7WebRequest -Path '/controller/p' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $permanentStatus = ( $response.Content | ConvertFrom-JSON ).controller
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    
 

        $response = Invoke-JS7WebRequest -Path '/controllers/p' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $clusterStatus = ( $response.Content | ConvertFrom-JSON ).controllers
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    

        $returnStatus = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'Volatile' -value $volatileStatus -InputObject $returnStatus
        Add-Member -Membertype NoteProperty -Name 'Permanent' -value $permanentStatus -InputObject $returnStatus
        
        foreach( $clusterNodeInstance in $clusterStatus )
        {
            if ( $clusterNodeInstance.Url -eq $volatileStatus.Url )
            {
                if ( !$volatileStatus.clusterNodeState -or $volatileStatus.clusterNodeState._text -eq 'active' )
                {
                    Add-Member -Membertype NoteProperty -Name 'Active' -value $clusterNodeInstance -InputObject $returnStatus
                } else {
                    Add-Member -Membertype NoteProperty -Name 'Passive' -value $clusterNodeInstance -InputObject $returnStatus
                }
            } else {
                if ( $volatileStatus.clusterNodeState._text -eq 'active' )
                {
                    Add-Member -Membertype NoteProperty -Name 'Passive' -value $clusterNodeInstance -InputObject $returnStatus
                } else {
                    Add-Member -Membertype NoteProperty -Name 'Active' -value $clusterNodeInstance -InputObject $returnStatus
                }
            }
        }
        
        if ( $Display )
        {
            $output = "
________________________________________________________________________
....... Controller ID: $($returnStatus.Permanent.controllerId)
............. version: $($returnStatus.Permanent.version)
................. url: $($returnStatus.Volatile.url)
................ role: $($returnStatus.Volatile.role)
............... title: $($returnStatus.Permanent.title)
....... running since: $($returnStatus.Volatile.startedAt)
...... security level: $($returnStatus.Permanent.securityLevel)
..... cluster coupled: $($returnStatus.Volatile.isCoupled)
.. cluster node state: $($returnStatus.Volatile.clusterNodeState._text)
..... component state: $($returnStatus.Volatile.componentState._text)
.... connection state: $($returnStatus.Volatile.connectionState._text)"

            foreach( $cluster in $returnStatus.cluster )
            {
                $output += "
......... cluster url: $($cluster.clusterUrl)
................ role:   $($cluster.role)
.................. OS:   $($cluster.os.name), $($cluster.os.architecture), $($cluster.os.distribution)"
            }
            
             $output += "
________________________________________________________________________"
            Write-Output $output
        }
        
        if ( $Summary )
        {
            $response = Invoke-JS7WebRequest -Path '/orders/overview/snapshot' -Body $requestBody
    
            if ( $response.StatusCode -eq 200 )
            {
                $orderSummary = ( $response.Content | ConvertFrom-JSON ).orders
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }    

            $response = Invoke-JS7WebRequest -Path '/jobs/overview/snapshot' -Body $requestBody
    
            if ( $response.StatusCode -eq 200 )
            {
                $jobSummary = ( $response.Content | ConvertFrom-JSON ).jobs
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }    

            if ( $Display )
            {
                $output = "
________________________________________________________________________
Orders    
............. pending: $($orderSummary.pending)
............. running: $($orderSummary.running)
........... suspended: $($orderSummary.suspended)
.............. failed: $($orderSummary.failed)
............. waiting: $($orderSummary.waiting)
............. blocked: $($orderSummary.blocked)
Jobs    
............. pending: $($jobSummary.pending)
............. running: $($jobSummary.running)
________________________________________________________________________
                "
                Write-Output $output
            }
            
            Add-Member -Membertype NoteProperty -Name 'OrderSummary' -value $orderSummary -InputObject $returnStatus
            Add-Member -Membertype NoteProperty -Name 'JobSummary' -value $jobSummary -InputObject $returnStatus
        }
        
        if ( !$Display )
        {
            $returnStatus
        }
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
