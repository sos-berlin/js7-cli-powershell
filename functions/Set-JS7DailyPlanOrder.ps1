function Set-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Returns the daily plan orders scheduled for a number of JS7 Controllers

.DESCRIPTION
The daily plan orders for workflows of a number of JS7 Controllers are returned.

The following REST Web Service API resources are used:

* /daily_plan/orders

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which daily plan orders should be returned.

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule for which daily plan orders should be returned.

.PARAMETER Folder
Optionally specifies the folder with workflows for which daily plan orders should be returned.

.PARAMETER Recursive
When used with the -Folder parameter then any sub-folders of the specified folder will be looked up.

.PARAMETER DateFrom
Optionally specifies the date starting from which daily plan orders should be returned.
Consider that a UTC date has to be provided.

Default: Beginning of the current day as a UTC date

.PARAMETER DateTo
Optionally specifies the date until which daily plan orders should be returned.
Consider that a UTC date has to be provided.

Default: End of the current day as a UTC date

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which daily plan orders should be returned, e.g.

* -1d, -2d: one day ago, two days ago
* +1d, +2d: one day later, two days later
* -1w, -2w: one week ago, two weeks ago
* +1w, +2w: one week later, two weeks later
* -1M, -2M: one month ago, two months ago
* +1M, +2M: one month later, two months later
* -1y, -2y: one year ago, two years ago
* +1y, +2y: one year later, two years later

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER RelativeDateTo
Specifies a relative date until which daily plan orders should be returned, e.g.

* -1d, -2d: one day ago, two days ago
* +1d, +2d: one day later, two days later
* -1w, -2w: one week ago, two weeks ago
* +1w, +2w: one week later, two weeks later
* -1M, -2M: one month ago, two months ago
* +1M, +2M: one month later, two months later
* -1y, -2y: one year ago, two years ago
* +1y, +2y: one year later, two years later

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.

This parameter takes precedence over the -DateTo parameter.

.PARAMETER Timezone
Specifies the timezone to which dates should be converted in the daily plan information.
A timezone can e.g. be specified like this:

  Get-JSDailyPlanOrder -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Get-JSDailyPlanOrder -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER Late
Specifies that daily plan orders are returned that are late or that started later than expected.

.PARAMETER Planned
Specifies that daily plan orders are returned that have not been submitted.

.PARAMETER Submitted
Specifies that daily plan orders are returned that are submitted to a Controller for scheduled execution.

.PARAMETER Finished
Specifies that daily plan orders are returned that did complete.

.OUTPUTS
This cmdlet returns an array of daily plan orders.

.EXAMPLE
$orders = ( Get-JS7DailyPlanOrder -Timezone (Get-Timezone) | Set-DailyPlanOrders -RelativeScheduledTime "+03:00:00"

Returns today's daily plan orders for any workflows with start times being moved forward 3 hours.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $ScheduledFor,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $RelativeScheduledFor,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [String] $ScheduledTime,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [String] $RelativeScheduledTime,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $Cycle,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Variables,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $RemoveVariables,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $StartPosition,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $EndPositions,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $BlockPosition,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForceJobAdmission,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( $ScheduledFor -and $RelativeScheduledFor )
        {
            throw 'only one of the arguments -ScheduledFor and -RelativeScheduledFor can be used'
        }

        if ( $ScheduledTime -and $RelativeScheduledTime )
        {time
            throw 'only one of the arguments -ScheduledTime and -RelativeScheduledTime can be used'
        }

        $orderIds = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter OrderID=$OrderID"

        if ( $OrderId )
        {
            $orderIds += $OrderId
        }
    }

    End
    {
<#
        # PowerShell/.NET does not create date output in the target timezone but with the local timezone only, let's work around this:
        $timezoneOffsetPrefix = if ( $Timezone.BaseUtcOffset.toString().startsWith( '-' ) ) { '-' } else { '+' }
        $timezoneOffsetHours = [Math]::Abs($Timezone.BaseUtcOffset.hours)

        if ( $Timezone.SupportsDaylightSavingTime -and $Timezone.IsDaylightSavingTime( (Get-Date) ) )
        {
            $timezoneOffsetHours += 1
        }

        [string] $timezoneOffset = "$($timezoneOffsetPrefix)$($timezoneOffsetHours.ToString().PadLeft( 2, '0' )):$($Timezone.BaseUtcOffset.Minutes.ToString().PadLeft( 2, '0' ))"
#>
        if ( $RelativeScheduledFor )
        {
            $dateDirection = $RelativeScheduledFor[0]
            $dateRange = $RelativeScheduledFor.Substring( 1, $RelativeScheduledFor.Length-2 )
            $dateUnit = $RelativeScheduledFor[$RelativeScheduledFor.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanScheduledFor = (Get-Date).AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanScheduledFor = (Get-Date).AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanScheduledFor = (Get-Date).AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanScheduledFor = (Get-Date).AddYears( "$($dateDirection)$($dateRange)" ) }
            }
        } else {
            $dailyPlanScheduledFor = Get-Date (Get-Date $ScheduledFor)
        }

        if ( $RelativeScheduledTime )
        {
            $dateDirection = $RelativeScheduledTime[0]
            $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddHours( "$($dateDirection)$($RelativeScheduledTime.Substring( 1, 2 ))" )
            $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddMinutes( "$($dateDirection)$($RelativeScheduledTime.Substring( 4, 2 ))" )
            $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddSeconds( "$($dateDirection)$($RelativeScheduledTime.Substring( 7, 2 ))" )
        } else {
            $dailyPlanScheduledFor = Get-Date (Get-Date $DailyPlanScheduledFor)
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): updating daily plan for date $dailyPlanScheduledFor"

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value (Get-Date $dailyPlanScheduledFor -Format 'yyyy-MM-dd HH:mm:ss') -InputObject $body

        if ( $orderIds )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body
        }

        if ( $Cycle )
        {
            $scheduledCycle = New-Object PSObject
            if ( $Cycle.begin )
            {
                if ( $RelativeScheduledTime )
                {                                
                    $ts = ([TimeSpan]::Parse($Cycle.begin.Substring(11, 8)))
                    
                    if ( $RelativeScheduledTime[0] -eq '-' )
                    {
                        $ts -= ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    } else {
                        $ts += ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    }
    
                    Add-Member -Membertype NoteProperty -Name 'begin' -value $ts.toString("hh\:mm\:ss") -InputObject $scheduledCycle
                } else {
                    Add-Member -Membertype NoteProperty -Name 'begin' -value $Cycle.begin.Substring(11, 8) -InputObject $scheduledCycle
                }
            }
            
            if ( $Cycle.end )
            {
                if ( $RelativeScheduledTime )
                {                                
                    $ts = ([TimeSpan]::Parse($Cycle.end.Substring(11, 8)))
                    
                    if ( $RelativeScheduledTime[0] -eq '-' )
                    {
                        $ts -= ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    } else {
                        $ts += ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    }
    
                    Add-Member -Membertype NoteProperty -Name 'end' -value $ts.toString("hh\:mm\:ss") -InputObject $scheduledCycle
                } else {
                    Add-Member -Membertype NoteProperty -Name 'end' -value $Cycle.end.Substring(11, 8) -InputObject $scheduledCycle
                }
            }

            Add-Member -Membertype NoteProperty -Name 'repeat' -value ( "{0:hh\:mm\:ss}" -f ([timespan]::fromseconds($Cycle.repeat)) ) -InputObject $scheduledCycle

            Add-Member -Membertype NoteProperty -Name 'cycle' -value $scheduledCycle -InputObject $body
        }

        if ( $Variables )
        {
            Add-Member -Membertype NoteProperty -Name 'variables' -value $Variables -InputObject $body
        }

        if ( $RemoveVariables )
        {
            Add-Member -Membertype NoteProperty -Name 'removeVariables' -value @($RemoveVariables) -InputObject $body
        }

        if ( $StartPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'startPosition' -value $StartPosition -InputObject $body
        }

        if ( $EndPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'endPositions' -value @($EndPositions) -InputObject $body
        }

        if ( $BlockPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'blockPosition' -value $BlockPosition -InputObject $body
        }

        if ( $ForceJobAdmission )
        {
            Add-Member -Membertype NoteProperty -Name 'forceJobAdmission' -value ( $ForceJobAdmission -eq $True ) -InputObject $body
        }

        if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
        {
            $objAuditLog = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

            if ( $AuditTimeSpent )
            {
                Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
            }

            if ( $AuditTicketLink )
            {
                Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
            }

            Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
        }

        if ( $PSCmdlet.ShouldProcess( 'orders', '/daily_plan/orders/modify' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/daily_plan/orders/modify' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $dailyPlanItems = ( $response.Content | ConvertFrom-JSON ).orderIds
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $dailyPlanItems.count )
            {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($dailyPlanItems.count) Daily Plan orders updated"
            } else {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders updated"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
