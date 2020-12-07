function Get-JS7ControllerStatus
{
<#
.SYNOPSIS
Return status information, summary and history information from a JS7 Controller

.DESCRIPTION
Status information and summary information are returned from a JS7 Controller.

* Status information includes e.g. the start date and JS7 release
* Summary information includes e.g. the number of running orders
* History information includes e.g. an overview of past orders

.PARAMETER DateFrom
Specifies the date starting from which history items should be returned.
Consider that a UTC date has to be provided.

Default: Begin of the current day as a UTC date

.PARAMETER DateTo
Specifies the date until which history items should be returned.
Consider that a UTC date has to be provided.

Default: End of the current day as a UTC date

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which history items should be returned, e.g. 

* -1s, -2s: one second ago, two seconds ago
* -1m, -2m: one minute ago, two minutes ago
* -1h, -2h: one hour ago, two hours ago
* -1d, -2d: one day ago, two days ago
* -1w, -2w: one week ago, two weeks ago
* -1M, -2M: one month ago, two months ago
* -1y, -2y: one year ago, two years ago

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ, that is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER RelativeDateTo
Specifies a relative date until which history items should be returned, e.g. 

* -1s, -2s: one second ago, two seconds ago
* -1m, -2m: one minute ago, two minutes ago
* -1h, -2h: one hour ago, two hours ago
* -1d, -2d: one day ago, two days ago
* -1w, -2w: one week ago, two weeks ago
* -1M, -2M: one month ago, two months ago
* -1y, -2y: one year ago, two years ago

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ, that is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER Timezone
Specifies the timezone to which dates should be converted from the history information.

Default: Dates are returned in UTC.

.PARAMETER Summary
Specifies that summary information about orders and tasks should be returned.

.PARAMETER History
Specifies that history information about orders and tasks should be returned.

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
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date -Hour 0 -Minute 0 -Second 0).ToUniversalTime(),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(1).ToUniversalTime(),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $History,
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
................. URL: $($returnStatus.Volatile.url)
................ role: $($returnStatus.Volatile.role)
............... title: $($returnStatus.Permanent.title)
....... running since: $($returnStatus.Volatile.startedAt)
...... security level: $($returnStatus.Permanent.securityLevel)
..... cluster coupled: $($returnStatus.Volatile.isCoupled)
.. cluster node state: $($returnStatus.Volatile.clusterNodeState._text)
.... component status: $($returnStatus.Volatile.componentState._text)
... connection status: $($returnStatus.Volatile.connectionState._text)"

            foreach( $cluster in $returnStatus.cluster )
            {
                $output += "
......... cluster URL: $($cluster.clusterUrl)
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
Order Summary
............. pending: $($orderSummary.pending)
............. running: $($orderSummary.running)
........... suspended: $($orderSummary.suspended)
.............. failed: $($orderSummary.failed)
............. waiting: $($orderSummary.waiting)
............. blocked: $($orderSummary.blocked)
Task Summary
............. pending: $($jobSummary.pending)
............. running: $($jobSummary.running)
________________________________________________________________________"
                Write-Output $output
            }
            
            Add-Member -Membertype NoteProperty -Name 'OrderSummary' -value $orderSummary -InputObject $returnStatus
            Add-Member -Membertype NoteProperty -Name 'JobSummary' -value $jobSummary -InputObject $returnStatus
        }

        if ( $History )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            if ( $DateFrom -or $RelativeDateFrom )
            {
                if ( $RelativeDateFrom )
                {
                    if ( $RelativeDateFrom.endsWith( '+TZ' ) )
                    {
                        $RelativeDateFrom = $RelativeDateFrom.Substring( 0, $RelativeDateFrom.length-3 ) + $timezoneOffset
                    }
                    Add-Member -Membertype NoteProperty -Name 'dateFrom' -value $RelativeDateFrom -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'dateFrom' -value ( Get-Date (Get-Date $DateFrom).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
                }
            }

            if ( $DateTo -or $RelativeDateTo )
            {
                if ( $RelativeDateTo )
                {
                    if ( $RelativeDateTo.endsWith( '+TZ' ) )
                    {
                        $RelativeDateTo = $RelativeDateTo.Substring( 0, $RelativeDateTo.length-3 ) + $timezoneOffset
                    }
                    Add-Member -Membertype NoteProperty -Name 'dateTo' -value $RelativeDateTo -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'dateTo' -value ( Get-Date (Get-Date $DateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
                }
            }

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/orders/overview/summary' -Body $requestBody
    
            if ( $response.StatusCode -eq 200 )
            {
                $orderHistory = ( $response.Content | ConvertFrom-JSON ).orders
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }    


            $response = Invoke-JS7WebRequest -Path '/jobs/overview/summary' -Body $requestBody
    
            if ( $response.StatusCode -eq 200 )
            {
                $jobHistory = ( $response.Content | ConvertFrom-JSON ).jobs
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }    

            if ( $Display )
            {
                $output = "
________________________________________________________________________
Order History
.......... successful: $($orderHistory.successful)
.............. failed: $($orderHistory.failed)
Task History
............. pending: $($jobHistory.successful)
............. running: $($jobHistory.failed)
________________________________________________________________________"
                Write-Output $output
            }
            
            Add-Member -Membertype NoteProperty -Name 'OrderHistory' -value $orderHistory -InputObject $returnStatus
            Add-Member -Membertype NoteProperty -Name 'JobHistory' -value $jobHistory -InputObject $returnStatus
        }
        
        if ( !$Display )
        {
            $returnStatus
        } else {
            Write-Output ""
        }
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
