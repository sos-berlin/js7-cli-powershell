function Get-JS7AuditLog
{
<#
.SYNOPSIS
Returns Audit Log entries

.DESCRIPTION
Audit log information is returned from a JOC Cockpit instance.
Audit log entries can be selected by workflow path, order ID, folder etc.

The audit log information returned includes point in time, request, object etc. of a change.

The following REST Web Service API resources are used:

* /audit_log
* /audit_log/details

.PARAMETER Folder
Optionally specifies the folder that includes objects for which audit log entries should be returned.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up when used with the -Folder parameter.
By default no sub-folders will be looked up for workflow paths.

.PARAMETER Type
Specifies the object types for which audit log entries should be returned. Multiyple values can be specifed by
use of comma, for example -Type WORKFLOW,SCHEDULE

* WORKFLOW
* JOBRESOURCE
* LOCK
* FILEORDERSOURCE
* NOTICEBOARD
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* SCHEDULE
* INCLUDESCRIPT
* DOCUMENTATION
* ORDER

.PARAMETER ObjectName
Specifies the name of an object that matches one or more of the object types specified with the -Type parameter.
The object name can include * and ? wildcard characters with

* : match zero or more characters
? : match any single character

.PARAMETER Category
Specfies a category that further limits results of audit log entries.

* INVENTORY
* CONTROLLER
* DAILYPLAN
* DEPLOYMENT
* DOCUMENTATIONS
* CERTIFICATES
* IDENTITY

.PARAMETER DateFrom
Specifies the date starting from which audit log entries should be returned.
Consider that a UTC date has to be provided.

Default: Begin of the current day as a UTC date

.PARAMETER DateTo
Specifies the date until which audit log entries should be returned.
Consider that a UTC date has to be provided.

Default: End of the current day as a UTC date

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which audit log entries should be returned, e.g.

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
Specifies a relative date until which audit log entries should be returned, e.g.

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

All dates in JobScheduler are UTC and can be converted e.g. to the local time zone like this:

  Get-JS7OrderHistory -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER Account
Limits results to entries that have been caused by the specified account.

.PARAMETER TicketLink
Limits results to entries that inlcude the specified ticket link.

.PARAMETER Limit
Specifies the max. number of audit log entries to be returned.
The default value is 10000, for an unlimited number of items the value -1 can be specified.

.PARAMETER Detailed
Specifies that the original request should be returned that caused the change related to the respective audit log entry.
Consider that the -Detailed parameter can return large amounts of data and will slow down processing.

.OUTPUTS
This cmdlet returns an array of audit log entries.

.EXAMPLE
$items = Get-JS7AuditLog

Returns today's audit log entries.

.EXAMPLE
$items = Get-JS7AuditLog -Category 'DEPLOYMENT'

Returns today's audit log entries for any deployment related changes.

.EXAMPLE
$items = Get-JS7AuditLog -Category 'DEPLOYMENT' -Detailed

Returns today's audit log entries for any deployment related changes including details about each object.

.EXAMPLE
$items = Get-JS7AuditLog -Timezone (Get-Timezone)

Returns today's audit log entries with dates being converted to the local timezone.

.EXAMPLE
$items = Get-JS7AuditLog -Timezone (Get-Timezone -Id 'GMT Standard Time')

Returns today's audit log entries with dates being converted to the GMT timezone.

.EXAMPLE
$items = Get-JS7AuditLog -Folder /ProductDemo -Recursive

Returns today's audit log entries for a given folder and any sub-folders.

.EXAMPLE
$items = Get-JS7AuditLog -DateFrom "2020-08-11 14:00:00Z"

Returns the audit log entries that started after the specified UTC date and time.

.EXAMPLE
$items = Get-JS7AuditLog -DateFrom (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-7).ToUniversalTime()

Returns the audit log entries for the last seven days.

.EXAMPLE
$items = Get-JS7AuditLog -RelativeDateFrom -7d

Returns the audit log for the last seven days.
The audit log is reported starting from midnight UTC.

.EXAMPLE
$items = Get-JS7AuditLog -RelativeDateFrom -7d+01:00

Returns the audit log for the last seven days.
The audit log is reported starting from 1 hour after midnight UTC.

.EXAMPLE
$items = Get-JS7AuditLog -RelativeDateFrom -7d+TZ

Returns the audit log for the last seven days.
The audit log is reported starting from midnight in the same timezone that is used with the -Timezone parameter.

.EXAMPLE
$items = Get-JS7AuditLog -RelativeDateFrom -1w

Returns the audit log entries for the last week.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBRESOURCE','LOCK','FILEORDERSOURCE','NOTICEBOARD','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','INCLUDESCRIPT','DOCUMENTATION','ORDER',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('INVENTORY','CONTROLLER','DAILYPLAN','DEPLOYMENT','DOCUMENTATIONS','CERTIFICATES','IDENTITY',IgnoreCase = $False)]
    [string[]] $Category,
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
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Account,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $TicketLink,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Reason,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Detailed
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $folders = @()
        $types = @()
        $categories = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder"

        if ( $Folder -and $Folder -ne '/' )
        {
            if ( !$Folder.StartsWith( '/' ) )
            {
                $Folder = '/' + $Folder
            }

            if ( $Folder.endsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }

        if ( $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }

        if ( $Type )
        {
            $types += $Type
        }

        if ( $Category )
        {
            $categories += $Category
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

        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        }

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $types )
        {
            Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $types -InputObject $body
        }

        if ( $ObjectName )
        {
            Add-Member -Membertype NoteProperty -Name 'objectName' -value $ObjectName -InputObject $body
        }

        if ( $categories )
        {
            Add-Member -Membertype NoteProperty -Name 'categories' -value $categories -InputObject $body
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

        if ( $Account )
        {
            Add-Member -Membertype NoteProperty -Name 'account' -value $Account -InputObject $body
        }

        if ( $TicketLink )
        {
            Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $TicketLink -InputObject $body
        }

        if ( $Reason )
        {
            Add-Member -Membertype NoteProperty -Name 'comment' -value $Reason -InputObject $body
        }

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/audit_log' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnAuditLogItems = ( $response.Content | ConvertFrom-Json ).auditLog
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone.Id -eq 'UTC' )
        {
            $returnAuditLogItems
        } else {
            $returnAuditLogItems | Select-Object -Property `
                                           account, `
                                           category, `
                                           controllerId, `
                                           id, `
                                           parameters, `
                                           request, `
                                           @{name='created'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.created)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}
        }

        if ( $Detailed -and $returnAuditLogItems.count )
        {
            foreach( $returnAuditLogItem in $returnAuditLogItems )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'auditLogId' -value $returnAuditLogItem.Id -InputObject $body
                [string] $requestBody = $body | ConvertTo-Json
                $response = Invoke-JS7WebRequest -Path '/audit_log/details' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    Add-Member -Membertype NoteProperty -Name 'details' -value ( $response.Content | ConvertFrom-Json ).auditLogDetails -InputObject $returnAuditLogItem
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }
        }

        if ( $returnAuditLogItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnAuditLogItems.count) audit log entries found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no audit log entries found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
