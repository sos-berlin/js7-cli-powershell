function Get-JS7OrderHistory
{
<#
.SYNOPSIS
Returns the order execution history

.DESCRIPTION
History information is returned for orders from a JS7 Controller.
Order executions can be selected by workflow, Order ID, folder, history status etc.

The history information returned includes start time, end time, return code etc.

The following REST Web Service API resources are used:

* /orders/history

.PARAMETER OrderId
Optionally specifies the identifier of an order for which the order history should be returned.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which order history information is returned.

.PARAMETER Folder
Optionally specifies the folder that includes workflows for which the order history should be returned.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up when used with the -Folder parameter.
By default no sub-folders will be looked up for workflow paths.

.PARAMETER ExcludeWorkflow
This parameter accepts a list of workflow paths that are excluded from the results.
If a workflow path is specified then all orders of the given workflow are excluded.

.PARAMETER RegularExpression
Specifies that a regular expession is applied to Order IDs to filter results.
The Order ID includes the Order Name attribute that is specified when adding the order like this for an Order Name "myIdentifier":

    "#2020-11-19#P0000000498-myIdentifier"

A regular expression 'Identifier$' matches the above Order ID.

.PARAMETER DateFrom
Specifies the date starting from which history items should be returned.
Dates can be specified in any time zone.

Default should no Order ID be provided: Begin of current day in the current timezone

.PARAMETER DateTo
Specifies the date until which history items should be returned.
Dates can be specified in any time zone.

Default should no Order ID be provided: End of current day in the current timezone

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
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This is calculated by the cmdlet
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
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateTo parameter.

.PARAMETER Timezone
Specifies the timezone to which dates should be converted from the history information.
A timezone can be specified like this:

  Get-JS7OrderHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Get-JS7OrderHistory -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER Limit
Specifies the max. number of history items for order executions to be returned.
The default value is 10000, for an unlimited number of items the value -1 can be specified.

.PARAMETER Successful
Returns history information for successfully completed orders.

.PARAMETER Failed
Returns history information for failed orders.

.PARAMETER InProgress
Specifies that history information for running orders should be returned.

.PARAMETER WorkflowId
This is an implicit parameter used when pipelining order objects to this cmdlet as e.g. with

   Get-JS7Order -Folder /some_path | Get-JS7OrderHistory

.OUTPUTS
This cmdlet returns an array of history items.

.EXAMPLE
$items = Get-JS7OrderHistory

Returns today's order execution history for any orders.

.EXAMPLE
$items = Get-JS7OrderHistory -RegularExpression 'sos$'

Returns today's order execution history for any orders with an Order ID that ends with the string "sos".

.EXAMPLE
$items = Get-JS7OrderHistory -Timezone (Get-Timezone)

Returns today's order execution history for any orders with dates being converted to the local timezone.

.EXAMPLE
$items = Get-JS7OrderHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

Returns today's order execution history for any orders with dates being converted to the GMT timezone.

.EXAMPLE
$items = Get-JS7OrderHistory -WorkflowPath /some_path/some_workflow

Returns today's order execution history for a given workflow.

.EXAMPLE
$items = Get-JS7OrderHistory -ExcludeWorkflow workflow1,workflow2

Returns today's order execution history for any orders excluding orders from the specified workflows.

.EXAMPLE
$items = Get-JS7OrderHistory -Successful -DateFrom "2020-08-11 14:00:00Z"

Returns the order execution history for successfully completed orders that started after the specified UTC date and time.

.EXAMPLE
$items = Get-JS7OrderHistory -Failed -DateFrom (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-7).ToUniversalTime()

Returns the order execution history for any failed orders for the last seven days.

.EXAMPLE
$items = Get-JS7OrderHistory -RelativeDateFrom -7d

Returns the order execution history for the last seven days.
The history is reported starting from midnight UTC.

.EXAMPLE
$items = Get-JS7OrderHistory -RelativeDateFrom -7d+01:00

Returns the order execution history for the last seven days.
The history is reported starting from 1 hour after midnight UTC.

.EXAMPLE
$items = Get-JS7OrderHistory -RelativeDateFrom -7d+TZ

Returns the order execution history for the last seven days.
The history is reported starting from midnight in the same timezone that is used with the -Timezone parameter.

.EXAMPLE
$items = Get-JS7OrderHistory -RelativeDateFrom -1w

Returns the order execution history for the last week.

.EXAMPLE
$items = Get-JS7OrderHistory -Folder /sos -Recursive -Successful -Failed

Returns today's order execution history for any completed orders from the "/sos" folder
and any sub-folders recursively.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $ExcludeWorkflow,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RegularExpression,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date -Format 'yyyy-MM-dd'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Successful,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Failed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $InProgress,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $WorkflowId
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $orders = @()
        $folders = @()
        $historyStates = @()
        $excludeWorkflows = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, OrderId=$OrderId"

        if ( $WorkflowId -and $WorkflowId.path -and !$WorkflowPath )
        {
            $WorkflowPath = $WorkflowId.path
        }

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

        if ( $Folder -eq '/' -and !$WorkflowPath -and !$OrderId -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $Successful -and 'SUCCESSFUL' -notin $historyStates )
        {
            $historyStates += 'SUCCESSFUL'
        }

        if ( $Failed -and 'FAILED' -notin $historyStates )
        {
            $historyStates += 'FAILED'
        }

        if ( $InProgress -and 'INCOMPLETE' -notin $historyStates )
        {
            $historyStates += 'INCOMPLETE'
        }

        if ( !$OrderId -and !$DateFrom )
        {
            $DateFrom = (Get-Date -Hour 0 -Minute 0 -Second 0)
        }

        if ( !$OrderId -and !$DateTo )
        {
            $DateTo = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(1)
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
        } elseif ( $Folder ) {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }

        if ( $ExcludeWorkflow )
        {
            $excludeWorkflows += $ExcludeWorkflow
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
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        if ( $orders )
        {
            Add-Member -Membertype NoteProperty -Name 'orders' -value $orders -InputObject $body
        }

        if ( $excludeWorkflows )
        {
            Add-Member -Membertype NoteProperty -Name 'excludeWorkflows' -value $excludeWorkflows -InputObject $body
        }

        if ( $WorkflowName )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowName' -value $WorkflowName -InputObject $body
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

        if ( $historyStates )
        {
            Add-Member -Membertype NoteProperty -Name 'historyStates' -value $historyStates -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/orders/history' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnHistoryItems = ( $response.Content | ConvertFrom-Json ).history
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone -and $Timezone.Id -ne 'UTC' )
        {
            foreach( $returnHistoryItem in $returnHistoryItems )
            {
                $returnHistoryItem.surveyDate = ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($returnHistoryItem.surveyDate)".SubString(0, 19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset

                if ( $returnHistoryItem.plannedTime )
                {
                    $returnHistoryItem.plannedTime = ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($returnHistoryItem.plannedTime)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset
                }

                if ( $returnHistoryItem.startTime )
                {
                    $returnHistoryItem.startTime = ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($returnHistoryItem.startTime)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset
                }

                if ( $returnHistoryItem.endTime )
                {
                    $returnHistoryItem.endTime = ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($returnHistoryItem.endTime)".SubString(0,19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset
                }
            }
        }

        $returnHistoryItems

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
