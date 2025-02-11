function Get-JS7Notification
{
<#
.SYNOPSIS
Returns Notification entries

.DESCRIPTION
Notifications are returned from a JOC Cockpit instance. Notifications can be selected by Controller ID and date.

Note that by default notifications are purged from the database after one day.

The following REST Web Service API resources are used:

* /monitoring/notifications

.PARAMETER ControllerId
Optionally specifies the unique identifier of the Controller for which notifications should be returned.


.PARAMETER DateFrom
Specifies the date starting from which notifications should be returned.
The date can be specified from any time zone.

Default: Beginning of current day in UTC timezone

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which notifications should be returned, for example

* -1s, -2s: one second ago, two seconds ago
* -1m, -2m: one minute ago, two minutes ago
* -1h, -2h: one hour ago, two hours ago
* -1d, -2d: one day ago, two days ago
* -1w, -2w: one week ago, two weeks ago
* -1M, -2M: one month ago, two months ago
* -1y, -2y: one year ago, two years ago

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER RelativeDateTo
Specifies a relative date until which notifications should be returned, for example

* -1s, -2s: one second ago, two seconds ago
* -1m, -2m: one minute ago, two minutes ago
* -1h, -2h: one hour ago, two hours ago
* -1d, -2d: one day ago, two days ago
* -1w, -2w: one week ago, two weeks ago
* -1M, -2M: one month ago, two months ago
* -1y, -2y: one year ago, two years ago

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER Timezone
Specifies the timezone to which dates should be converted from the history information.
A timezone can e.g. be specified like this:

  Get-JS7Notification -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Get-JS7Notification -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER Limit
Specifies the max. number of notifications to be returned.
The default value is 10000, for an unlimited number of items the value -1 can be specified.

.OUTPUTS
This cmdlet returns an array of notifications.

.EXAMPLE
$items = Get-JS7Notification

Returns today's notifications.

.EXAMPLE
$items = Get-JS7Notification -DateFrom "2020-08-11 14:00:00Z"

Returns the notifications that were created after the specified UTC date and time.

.EXAMPLE
$items = Get-JS7Notification -DateFrom (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-7)

Returns the notifications since the last seven days calculated in the current timezone.

.EXAMPLE
$items = Get-JS7Notification -RelativeDateFrom -1d

Returns notifications for the last day.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date -Hour 0 -Minute 0 -Second 0),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter DateFrom=$DateFrom"
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

        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

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

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/monitoring/notifications' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnNotificationItems = ( $response.Content | ConvertFrom-Json ).notifications
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone -and $Timezone.Id -ne 'UTC' )
        {
            foreach( $returnNotificationItem in $returnNotificationItems )
            {
                Add-Member -Membertype NoteProperty -Name 'jobs' -value $returnNotificationItem.job -InputObject $returnNotificationItem
                $returnNotificationItem.created = ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($returnNotificationItem.created)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset
            }
        }

        $returnNotificationItems

        if ( $returnNotificationItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnNotificationItems.count) notifications found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no notifications found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
