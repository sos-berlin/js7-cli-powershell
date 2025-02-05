function Get-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Returns the daily plan orders scheduled for a number of JS7 Controllers

.DESCRIPTION
The daily plan orders for workflows of a number of JS7 Controllers are returned.

The following REST Web Service API resources are used:

* /daily_plan/orders

.PARAMETER OrderId
Optionally specifies one or more Order IDs that identify orders in the daily plan.

.PARAMETER WorkflowPath
Optionally specifies the path and/or name of a workflow for which daily plan orders should be returned.

.PARAMETER SchedulePath
Optionally specifies the path and/or name of a schedule for which daily plan orders should be returned.

.PARAMETER Folder
Optionally specifies the folder with workflows for which daily plan orders should be returned.

.PARAMETER Recursive
When used with the -Folder parameter then any sub-folders of the specified folder will be looked up.

.PARAMETER ControllerId
Limits results to orders assigned the specified Controller.

.PARAMETER Tag
Filters orders by a list of tags.

If more than one tag is specified then they are separated by comma.

.PARAMETER DateFrom
Optionally specifies the date starting from which daily plan orders should be returned.
A date in the local time zone can be specified and will be converted to UTC.

Default: The current day in the local time zone

.PARAMETER DateTo
Optionally specifies the date until which daily plan orders should be returned.
A date in the local time zone can be specified and will be converted to UTC.

Default: The current day in the local time zone

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
Specifies the timezone to which dates should be converted in the daily plan return information.
A timezone can be specified like this:

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
$orders = Get-JS7DailyPlanOrder

Returns daily plan orders for the current day.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -Timezone (Get-Timezone)

Returns today's daily plan orders for any workflows with dates being converted to the local timezone.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -Timezone (Get-Timezone -Id 'GMT Standard Time')

Returns today's daily plan orders for any workflows with dates being converted to the GMT timezone.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -DateTo (Get-Date).AddDays(3)

Returns the daily plan orders for the next 3 days.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -RelativeDateFrom -3d

Returns the daily plan orders for the last three days.
The daily plan is reported starting from midnight UTC.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -Submitted -Late

Returns today's daily plan orders that have been submitted but are late, i.e. that did not start at the expected point in time.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -WorkflowPath /ap/apWorkflow1b

Returns the daily plan orders for the indicated workflow.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowFolder,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ScheduleFolder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Tag,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Late,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Planned,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Submitted,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Finished
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $orderIds = @()
        $workflowPaths = @()
        $workflowFolders = @()
        $schedulePaths = @()
        $scheduleFolders = @()
        $controllerIds = @()
        $tags = @()
        $states = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter WorkfowFolder=$WorkflowFolder, WorkflowPath=$WorkflowPath, SchedulePath=$SchedulePath, ScheduleFolder=$ScheduleFolder"

        if ( ( $Planned -and $Submitted ) -or ( $Planned -and $Finished ) -or ( $Submitted -and $Finished ) )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Planned or -Submitted or -Finished can be used"
        }

        if ( $WorkflowFolder -and $WorkflowFolder -ne '/' )
        {
            if ( !$WorkflowFolder.startsWith( '/' ) ) {
                $WorkflowFolder = '/' + $WorkflowFolder
            }

            if ( $WorkflowFolder.endsWith( '/' ) )
            {
                $WorkflowFolder = $WorkflowFolder.Substring( 0, $WorkflowFolder.Length-1 )
            }
        }

        if ( $ScheduleFolder -and $ScheduleFolder -ne '/' )
        {
            if ( !$ScheduleFolder.startsWith( '/' ) ) {
                $ScheduleFolder = '/' + $ScheduleFolder
            }

            if ( $ScheduleFolder.endsWith( '/' ) )
            {
                $ScheduleFolder = $ScheduleFolder.Substring( 0, $ScheduleFolder.Length-1 )
            }
        }


        if ( $Planned )
        {
            $states += 'PLANNED'
        }

        if ( $Submitted )
        {
            $states += 'SUBMITTED'
        }

        if ( $Finished )
        {
            $states += 'FINISHED'
        }

        if ( $OrderId )
        {
            $orderIds += $OrderId
            $date = ( $OrderId | Select-String -Pattern "^#(\d{4}-\d{2}-\d{2})#" ).matches.groups[1].value

            if ( !$DateFrom )
            {
                $DateFrom = Get-Date $date
            } elseif ( (Get-Date $date) -lt (Get-Date $DateFrom) ) {
                $DateFrom = $date
            }

            if ( !$DateTo )
            {
                $DateTo = Get-Date $date
            } elseif ( (Get-Date $date) -gt (Get-Date $DateTo) ) {
                $DateTo = $date
            }
        }

        if ( $WorkflowPath )
        {
            $workflowPaths += $WorkflowPath
        }

        if ( $WorkflowFolder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $WorkflowFolder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $workflowFolders += $objFolder
        }

        if ( $SchedulePath )
        {
            $schedulePaths += $SchedulePath
        }

        if ( $ScheduleFolder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $ScheduleFolder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $scheduleFolders += $objFolder
        }

        if ( $ControllerId )
        {
            $controllerIds += $ControllerId
        }

        if ( $Tag )
        {
            $tags += $Tag
        }
    }

    End
    {
        # PowerShell/.NET does not create date output in the target timezone but with the local timezone only, let's work around this:
        $timezoneOffsetPrefix = if ( $Timezone.BaseUtcOffset.toString().startsWith( '-' ) ) { '-' } else { '+' }
        $timezoneOffsetHours = [Math]::Abs($Timezone.BaseUtcOffset.hours)

        if ( $Timezone.SupportsDaylightSavingTime -and $Timezone.IsDaylightSavingTime( (Get-Date) ) )
        {
            $timezoneOffsetHours += 1
        }

        [string] $timezoneOffset = "$($timezoneOffsetPrefix)$($timezoneOffsetHours.ToString().PadLeft( 2, '0' )):$($Timezone.BaseUtcOffset.Minutes.ToString().PadLeft( 2, '0' ))"

        if ( $RelativeDateFrom )
        {
            $dateDirection = $RelativeDateFrom[0]
            $dateRange = $RelativeDateFrom.Substring( 1, $RelativeDateFrom.Length-2 )
            $dateUnit = $RelativeDateFrom[$RelativeDateFrom.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanDateFrom = (Get-Date).AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanDateFrom = (Get-Date).AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanDateFrom = (Get-Date).AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanDateFrom = (Get-Date).AddYears( "$($dateDirection)$($dateRange)" ) }
            }

            $dailyPlanDateFrom = Get-Date $dailyPlanDateFrom -Format 'yyyy-MM-dd'
        } else {
            $dailyPlanDateFrom = Get-Date $DateFrom -Format 'yyyy-MM-dd'
        }

        if ( $RelativeDateTo )
        {
            $dateDirection = $RelativeDateTo[0]
            $dateRange = $RelativeDateTo.Substring( 1, $RelativeDateTo.Length-2 )
            $dateUnit = $RelativeDateTo[$RelativeDateTo.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanDateTo = (Get-Date).AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanDateTo = (Get-Date).AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanDateTo = (Get-Date).AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanDateTo = (Get-Date).AddYears( "$($dateDirection)$($dateRange)" ) }
            }

            $dailyPlanDateTo = Get-Date $dailyPlanDateTo -Format 'yyyy-MM-dd'
        } else {
            if ( !$DateTo )
            {
                $dailyPlanDateTo = Get-Date $dailyPlanDateFrom -Format 'yyyy-MM-dd'
            } else {
                $dailyPlanDateTo = Get-Date $DateTo -Format 'yyyy-MM-dd'
            }
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): retrieving daily plan for date range $dailyPlanDateFrom - $dailyPlanDateTo"

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        Add-Member -Membertype NoteProperty -Name 'dailyPlanDateFrom' -value "$($dailyPlanDateFrom)" -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'dailyPlanDateTo' -value "$($dailyPlanDateTo)" -InputObject $body

        if ( $orderIds )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body
        }

        if ( $workflowPaths )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths -InputObject $body
        }

        if ( $workflowFolders )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowFolders' -value $workflowFolders -InputObject $body
        }

        if ( $schedulePaths )
        {
            Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePaths -InputObject $body
        }

        if ( $scheduleFolders )
        {
            Add-Member -Membertype NoteProperty -Name 'scheduleFolders' -value $scheduleFolders -InputObject $body
        }

        if ( $controllerIds )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value @( $script:jsWebService.ControllerId ) -InputObject $body
        }

        if ( $tags )
        {
            Add-Member -Membertype NoteProperty -Name 'tags' -value $tags -InputObject $body
        }

        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        if ( $Late )
        {
            Add-Member -Membertype NoteProperty -Name 'late' -value ( $Late -eq $True ) -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/daily_plan/orders' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $dailyPlanItems = ( $response.Content | ConvertFrom-JSON ).plannedOrderItems
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone.Id -eq 'UTC' )
        {
            $dailyPlanItems | Sort-Object plannedStartTime
        } else {
            $dailyPlanItems | Sort-Object plannedStartTime | Select-Object -Property `
                                           controllerId, `
                                           workflowPath, `
                                           historyId, `
                                           late, `
                                           orderId, `
                                           orderName, `
                                           period, `
                                           schedulePath, `
                                           startMode, `
                                           state, `
                                           @{name='plannedStartTime'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.plannedStartTime)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='expectedEndTime';  expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.expectedEndTime)".SubString(0,19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='startTime'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.startTime)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='endTime';  expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.endTime)".SubString(0,19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='surveyDate'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.surveyDate)".SubString(0, 19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}
        }

        if ( $dailyPlanItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($dailyPlanItems.count) Daily Plan orders found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
