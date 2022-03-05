function Get-JS7OrderSnapshot
{
<#
.SYNOPSIS
Returns the snashot summary of order states

.DESCRIPTION
The cmdlet returns the summary of order states for a given period.

The following REST Web Service API resources are used:

* /orders/overview/snapshot

.PARAMETER DateTo
Specifies the date until which history items should be returned.
Consider that a UTC date has to be provided.

Default should no order ID be provided: End of the current day as a UTC date

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
A timezone can e.g. be specified like this:

  Get-JS7OrderHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Get-JS7OrderHistory -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.OUTPUTS
This cmdlet returns an array of snapshot items.

.EXAMPLE
$items = Get-JS7OrderSnapshot

Returns today's order execution history for any orders.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC')
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter RelativeDateTo=$RelativeDateTo"
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
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

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
        $response = Invoke-JS7WebRequest -Path '/orders/overview/snapshot' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnSnapshotItems = ( $response.Content | ConvertFrom-Json ).orders
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $returnSnapshotItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnSnapshotItems.count) snapshot items found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no snapshot items found"
        }

        $returnSnapshotItems

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
