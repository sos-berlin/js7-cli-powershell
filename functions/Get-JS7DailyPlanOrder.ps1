function Get-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Returns the daily plan orders for workflows scheduled for a JS7 Controller

.DESCRIPTION
The daily plan orders for workflows are returned.

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

Default: Begin of the current day as a UTC date

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

All dates in JobScheduler are UTC and can be converted e.g. to the local time zone like this:

  Get-JSDailyPlanOrder -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER Late
Specifies that daily plan orders are returned that are late or that started later than expected.

.PARAMETER Successful
Specifies that daily plan orders are returned completed successfully.

.PARAMETER Failed
Specifies that daily plan orders are returned that completed with errors.

.PARAMETER InProgress
Specifies that daily plan orders are returned for workflows that did not yet complete.

.PARAMETER Planned
Specifies that daily plan orders are returned that did not yet start.

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
$orders = Get-JS7DailyPlanOrder -Failed -Late

Returns today's daily plan orders that failed or are late, i.e. that did not start at the expected point in time.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -WorkflowPath /ap/apWorkflow1b

Returns the daily plan orders for the given workflow.

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
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date (Get-Date).ToUniversalTime() -Format 'yyyy-MM-dd'),
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
        $states = @()
        $returnDailyPlanItems = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter WorkfowFolder=$WorkflowFolder, WorkflowPath=$WorkflowPath, SchedulePath=$SchedulePath, ScheduleFolder=$ScheduleFolder"

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
        } else {
            $dailyPlanDateFrom = Get-Date (Get-Date $DateFrom)
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
        } else {
            if ( !$DateTo )
            {
                $DateTo = $dailyPlanDateFrom
            }

            $dailyPlanDateTo = Get-Date (Get-Date $DateTo)
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): retrieving daily plan for date range $dailyPlanDateFrom - $dailyPlanDateTo"

        for( $day=$dailyPlanDateFrom; $day -le $dailyPlanDateTo; $day=$day.AddDays(1) )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            $filter = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'dailyPlanDate' -value (Get-Date $day -Format 'yyyy-MM-dd') -InputObject $filter

            if ( $orderIds )
            {
                Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $filter
            }

            if ( $workflowPaths )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths -InputObject $filter
            }

            if ( $workflowFolders )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowFolders' -value $workflowFolders -InputObject $filter
            }

            if ( $schedulePaths )
            {
                Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePaths -InputObject $filter
            }

            if ( $scheduleFolders )
            {
                Add-Member -Membertype NoteProperty -Name 'scheduleFolders' -value $scheduleFolders -InputObject $filter
            }

            if ( $controllerIds )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $filter
            }

            if ( $states )
            {
                Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $filter
            }

            if ( $Late )
            {
                Add-Member -Membertype NoteProperty -Name 'late' -value ( $Late -eq $True ) -InputObject $filter
            }

            if ( $filter )
            {
               Add-Member -Membertype NoteProperty -Name 'filter' -value $filter -InputObject $body
            }

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/daily_plan/orders' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $dailyPlanItems = ( $response.Content | ConvertFrom-JSON ).plannedOrderItems
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            $returnDailyPlanItems += $dailyPlanItems
        }

        if ( $Timezone.Id -eq 'UTC' )
        {
            $returnDailyPlanItems | Sort-Object plannedStartTime
        } else {
            $returnDailyPlanItems | Sort-Object plannedStartTime | Select-Object -Property `
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

        if ( $returnDailyPlanItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnDailyPlanItems.count) Daily Plan orders found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
