function Get-JS7TaskHistory
{
<#
.SYNOPSIS
Returns the task execution history for jobs

.DESCRIPTION
History information is returned for jobs from a JS7 Controller.
Task executions can be selected by job name, workflow, folder, history status etc.

The history information retured includes start time, end time, return code etc.

.PARAMETER Job
Optionally specifies the name of a job for which task execution results are reported.

This parameter requires use of the -WorkflowPath parameter to specify the workflow
that includes the job.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow that includes jobs
for which the task history is reported. The task execution history optionally can futher
be limited by specifying the -Job parameter to limit results to a job in the given workflow.

.PARAMETER OrderId
Optionally specifies the identifier of an order to limit results to jobs that
have been executed for the given order.

.PARAMETER Position
Optionally specifies the position in a workflow to limit results to jobs that
correspond to the given position in a workflow. This parameter requires use of the -OrderId parameter.

.PARAMETER Folder
Optionally specifies the folder that includes workflows for which the task history should be returned.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up when used with the -Folder parameter.
By default no sub-folders will be looked up for jobs.

.PARAMETER ExcludeJob
This parameter accepts a hashmap of job names and optionally workflow paths that are excluded from the results.
If a workflow path is specified then all jobs of the given workflow are excluded.

.PARAMETER RegularExpression
Specifies a regular expression that filters the jobs to be returned.
The regular expression is applied to the job name.

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
Specifies the timezone to which dates should be converted in the history information.
A timezone can e.g. be specified like this:

  Get-JSTaskHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JobScheduler are UTC and can be converted e.g. to the local time zone like this:

  Get-JSTaskHistory -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER TaskId
Specifies to report the execution history for the given task ID only.

.PARAMETER Limit
Specifies the max. number of history items for task executions to be returned.
The default value is 10000, for an unlimited number of items the value -1 can be specified.

.PARAMETER NormalCriticality
Specifies to return the task history for jobs only that are assigned a "normal" criticality.

.PARAMETER MinorCriticality
Specifies to return the task history for jobs only that are assigned a "minor" criticality.

.PARAMETER MajorCriticality
Specifies to return the task history for jobs only that are assigned a "major" criticality.

.PARAMETER Successful
Returns history information for successfully completed tasks.

.PARAMETER Failed
Returns history information for failed tasks.

.PARAMETER InProgress
Specifies that history information for running tasks should be returned.

.OUTPUTS
This cmdlet returns an array of history items.

.EXAMPLE
$items = Get-JS7TaskHistory

Returns today's task execution history for any jobs.

.EXAMPLE
$items = Get-JS7TaskHistory -RegularExpression "sos$"

Returns today's task execution history for any jobs with a job name that ends with "sos".

.EXAMPLE
$items = Get-JS7TaskHistory -Timezone (Get-Timezone)

Returns today's task execution history for any jobs with dates being converted to the local timezone.

.EXAMPLE
$items = Get-JS7TaskHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

Returns today's task execution history for any jobs with dates being converted to the GMT timezone.

.EXAMPLE
$items = Get-JS7TaskHistory -Job /sos/dailyplan/CreateDailyPlan

Returns today's task execution history for a given job.

.EXAMPLE
$items = Get-JS7TaskHistory -WorkflowPath /some_path/some_workflow

Returns today's task execution history for jobs in the given workflow.

.EXAMPLE
$items = Get-JS7TaskHistory -ExcludeJob @{ 'workflowPath'='/some_path/some_workflow'; 'job'='some_job' }

Returns today's task execution history for any jobs excluding the specified workflow paths and job names.

.EXAMPLE
$items = Get-JS7TaskHistory -Successful -DateFrom "2020-08-11 14:00:00Z"

Returns the task execution history for successfully completed jobs that started after the specified UTC date and time.

.EXAMPLE
$items = Get-JS7TaskHistory -Failed -DateFrom (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-7).ToUniversalTime()

Returns the task execution history for any failed jobs for the last seven days.

.EXAMPLE
$items = Get-JS7TaskHistory -RelativeDateFrom -7d

Returns the task execution history for the last seven days.
The history is reported starting from midnight UTC.

.EXAMPLE
$items = Get-JS7TaskHistory -RelativeDateFrom -7d+01:00

Returns the task execution history for the last seven days.
The history is reported starting from 1 hour after midnight UTC.

.EXAMPLE
$items = Get-JS7TaskHistory -RelativeDateFrom -7d+TZ

Returns the task execution history for any jobs for the last seven days.
The history is reported starting from midnight in the same timezone that is used with the -Timezone parameter.

.EXAMPLE
$items = Get-JS7TaskHistory -RelativeDateFrom -1w

Returns the task execution history for the last week.

.EXAMPLE
$items = Get-JS7TaskHistory -Folder /sos -Recursive -Successful -Failed

Returns today's task execution history for any completed tasks from the "/sos" directory
and any sub-folders recursively.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Job,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Position,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $ExcludeJob,
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
    [int] $TaskId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NormalCriticality,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $MinorCriticality,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $MajorCriticality,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Successful,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Failed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $InProgress
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $jobs = @()
        $orders = @()
        $folders = @()
        $criticalities = @()
        $historyStates = @()
        $excludeJobs = @()
        $taskIds = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath Job=$Job"

        if ( $Folder -and $Folder -ne '/' )
        {
            if ( !$Folder.StartsWith( '/' ) )
            {
                $Folder = '/' + $Folder
            }

            if ( $Folder.EndsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }

        if ( $Folder -eq '/' -and !$OrderId -and !$WorkflowPath -and !$Job -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $NormalCriticality )
        {
            $criticalities += 'NORMAL'
        }

        if ( $MinorCriticality )
        {
            $criticalities += 'MINOR'
        }

        if ( $MajorCriticality )
        {
            $criticalities += 'MAJOR'
        }

        if ( $Successful )
        {
            $historyStates += 'SUCCESSFUL'
        }

        if ( $Failed )
        {
            $historyStates += 'FAILED'
        }

        if ( $InProgress )
        {
            $historyStates += 'INCOMPLETE'
        }

        if ( $OrderId )
        {
            $objOrder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $objOrder

            if ( $WorkflowPath )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $WorkflowPath -InputObject $objOrder
            }

            if ( $Position )
            {
                Add-Member -Membertype NoteProperty -Name 'position' -value $Position -InputObject $objOrder
            }

            $orders += $objOrder
        }

        if ( $Job ) {
            $objJob = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'job' -value $Job -InputObject $objJob

            if ( $WorkflowPath )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $WorkflowPath -InputObject $objJob
            }

            $jobs += $objJob
        }

        if ( !$WorkflowPath -and $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $true) -InputObject $objFolder
            $folders += $objFolder
        }

        if ( $ExcludeJob )
        {
            foreach( $excludeJobItem in $ExcludeJob )
            {
                $objExcludeJob = New-Object PSObject

                if ( $excludeJobItem.job )
                {
                    Add-Member -Membertype NoteProperty -Name 'job' -value $excludeJobItem.job -InputObject $objExcludeJob
                }

                if ( $excludeJobItem.workflowPath )
                {
                    Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $excludeJobItem.workflowPath -InputObject $objExcludeJob
                }

                if ( $excludeJobItem.job -or $excludeJobItem.workflowPath )
                {
                    $excludeJobs += $objExcludeJob
                }
            }
        }

        if ( $TaskId )
        {
            $taskIds += $TaskId
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
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $jobs )
        {
            Add-Member -Membertype NoteProperty -Name 'jobs' -value $jobs -InputObject $body
        }

        if ( $excludeJobs )
        {
            Add-Member -Membertype NoteProperty -Name 'excludeJobs' -value $excludeJobs -InputObject $body
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

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
        }

        if ( $criticalities )
        {
            Add-Member -Membertype NoteProperty -Name 'criticalities' -value $criticalities -InputObject $body
        }

        if ( $historyStates )
        {
            Add-Member -Membertype NoteProperty -Name 'historyStates' -value $historyStates -InputObject $body
        }

        if ( $orders )
        {
            Add-Member -Membertype NoteProperty -Name 'orders' -value $orders -InputObject $body
        }

        if ( $taskIds )
        {
            Add-Member -Membertype NoteProperty -Name 'taskIds' -value $taskIds -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest '/tasks/history' $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnHistoryItems = ( $response.Content | ConvertFrom-JSON ).history
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone.Id -eq 'UTC' )
        {
            $returnHistoryItems
        } else {
            $returnHistoryItems | Select-Object -Property `
                                           controllerId, `
                                           agentUrl, `
                                           taskId, `
                                           orderId, `
                                           workflow, `
                                           position, `
                                           job, `
                                           criticality, `
                                           exitCode, `
                                           state, `
                                           @{name='startTime'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.startTime)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='endTime';  expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.endTime)".SubString(0,19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='surveyDate'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.surveyDate)".SubString(0, 19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}
        }

        if ( $returnHistoryItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnHistoryItems.count) history items found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no history items found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
