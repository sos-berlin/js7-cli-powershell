function Get-JS7AuditLog
{
<#
.SYNOPSIS
Returns the Audit Log entries

.DESCRIPTION
Audit log information is returned from a JOC Cockpit instance. 
Audit log entries can be selected by workflow path, order ID, folder etc.

The audit log information returned includes point in time, request, object etc.

.PARAMETER OrderId
Optionally specifies the identifier of an order for which audit log entries should be returned.

.PARAMETER Job
Optionally specifies the name of a job for which audit log entries should be returned.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which audit log information should be returned.

.PARAMETER Folder
Optionally specifies the folder that includes workflows for which audit log entries should be returned.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up when used with the -Folder parameter. 
By default no sub-folders will be looked up for workflow paths.

.PARAMETER RegularExpression
Specifies a regular expression that filters audit log entries to be returned.
The regular expression is applied to the order ID or job.

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

.PARAMETER Limit
Specifies the max. number of audit log entries to be returned.
The default value is 10000, for an unlimited number of items the value -1 can be specified.

.OUTPUTS
This cmdlet returns an array of audit log entries.

.EXAMPLE
$items = Get-JS7AuditLog

Returns today's audit log entries.

.EXAMPLE
$items = Get-JS7AuditLog -RegularExpression "sos$'

Returns today's audit log entries for any order IDs, workflow paths or job names end with the string "sos".

.EXAMPLE
$items = Get-JS7AuditLog -Timezone (Get-Timezone)

Returns today's audit log entries with dates being converted to the local timezone.

.EXAMPLE
$items = Get-JS7AuditLog -Timezone (Get-Timezone -Id 'GMT Standard Time')

Returns today's audit log entries with dates being converted to the GMT timezone.

.EXAMPLE
$items = Get-JS7AuditLog -WorkflowPath /some_path/some_workflow

Returns today's audit log entries for a given workflow.

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
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Job,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $CalendarPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RegularExpression,
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
    [int] $Limit
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        $orders = @()
        $jobs = @()
        $calendarPaths = @()
        $folders = @()
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, OrderId=$OrderId, Job=$Job, CalendarPath=$CalendarPath"

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
    
        if ( $Folder -eq '/' -and !$WorkflowPath -and !$OrderId -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $OrderId -or $WorkflowPath )
        {
            $objOrder = New-Object PSObject
                        
            if ( $OrderId )
            {
                Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $objOrder
            }
            
            if ( $WorkflowPath )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $WorkflowPath -InputObject $objOrder
            }

            $orders += $objOrder
        } elseif ( $Job -or $WorkflowPath ) {
            $objJob = New-Object PSObject
                        
            if ( $Job )
            {
                Add-Member -Membertype NoteProperty -Name 'job' -value $Job -InputObject $objJob
            }
            
            if ( $WorkflowPath )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $WorkflowPath -InputObject $obJob
            }

            $jobs += $objJob
        } elseif ( $CalendarPath ) {
                $calendarPaths += $CalendarPath
        } elseif ( $Folder -and $Folder -ne '/' ) {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }
    }
    
    End
    {
        # PowerShell/.NET does not create date output in the target timezone but with the local timezone only, let's work around this:
        $timezoneOffsetPrefix = if ( $Timezone.BaseUtcOffset.toString().startsWith( '-' ) ) { '-' } else { '+' }
        $timezoneOffsetHours = $Timezone.BaseUtcOffset.Hours

        if ( $Timezone.SupportsDaylightSavingTime -and $Timezone.IsDaylightSavingTime( (Get-Date) ) )
        {
            $timezoneOffsetHours += 1
        }
                    
        [string] $timezoneOffset = "$($timezoneOffsetPrefix)$($timezoneOffsetHours.ToString().PadLeft( 2, '0' )):$($Timezone.BaseUtcOffset.Minutes.ToString().PadLeft( 2, '0' ))"

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $orders )
        {
            Add-Member -Membertype NoteProperty -Name 'orders' -value $orders -InputObject $body
        }

        if ( $jobs )
        {
            Add-Member -Membertype NoteProperty -Name 'jobs' -value $jobs -InputObject $body
        }

        if ( $calendarPaths )
        {
            Add-Member -Membertype NoteProperty -Name 'calendars' -value $calendarPaths -InputObject $body
        }

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $RegularExpression )
        {
            Add-Member -Membertype NoteProperty -Name 'regex' -value $RegularExpression -InputObject $body
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

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/audit_log' -Body $requestBody
        
        if ( $response.StatusCode -eq 200 )
        {
            $returnAuditLogItems = ( $response.Content | ConvertFrom-JSON ).auditLog
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone.Id -eq 'UTC' )
        {
            $returnAuditLogItems
        } else {            
            $returnAuditLogItems | Select-Object -Property `
                                           account, `
                                           request, `
                                           parameters, `
                                           workflow, `
                                           orderId, `
                                           comment, `
                                           ticketLink, `
                                           timeSpent, `
                                           @{name='created'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.created)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}
        }

        if ( $returnAuditLogItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnAuditLogItems.count) audit log entries found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no audit log entries found"
        }
        
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
