function Get-JS7Order
{
<#
.SYNOPSIS
Returns orders from the JS7 Controller

.DESCRIPTION
Orders are selected from the JS7 Controller

* by the workflow that is assigned the order,
* by the folder of the worklow including sub-folders,
* by an individual Order ID.

Resulting orders can be forwarded to other cmdlets for pipelined bulk operations.

The following REST Web Service API resources are used:

* /order
* /orders

.PARAMETER OrderId
Optionally specifies the identifier of an order that should be returned.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which orders should be returned.

One of the -Folder, -WorkflowPath or -OrderId parameters has to be specified if no pipelined order objects are provided.

.PARAMETER WorkflowVersionId
Deployed workflows are assigned a version identifier. The argument allows to select the
workflow that is available with the specified version.

.PARAMETER Folder
Optionally specifies the folder with workflows for which orders should be returned.

One of the -Folder, -WorkflowPath or -OrderId parameters has to be specified if no pipelined order objects are provided.

.PARAMETER Recursive
Specifies that all sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be searched for orders.

.PARAMETER DateTo
Specifies the date and time until which orders should be returned.
Dates can be specified from any time zone, for example:

* 2025-02-25: begin of day for the indicated date
* 2025-02-25 17:18:19: specified time for the indicated date
* 2025-02-25 23:01:02+01:00: specified time and timezone for the indicated date
* (Get-Date).AddDays(1): current time one day ahead

Default should no Order ID be provided: End of current day in the given timezone

Only one of the -DateTo and -RelativeDateTo arguments can be used.

.PARAMETER RelativeDateTo
Specifies a relative date until which orders should be returned, e.g.

* 1s, 2s: one second later, two seconds later
* 1m, 2m: one minute later, two minutes later
* 1h, 2h: one hour later, two hours later
* 1d, 2d: one day later, two days later
* 1w, 2w: one week later, two weeks later
* 1M, 2M: one month later, two months later
* 1y, 2y: one year later, two years later

Optionally a time offset can be specified, e.g. 1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using 1d+TZ, that is calculated by the cmdlet
for the timezone that is specified with the -Timezone argument.

Only one of the -DateTo and -RelativeDateTo arguments can be used.

.PARAMETER Timezone
Specifies the timezone to which a relative date indicated with the -RelativeDateTo argument should be converted.
A timezone can e.g. be specified like this:

* Relative date specified for the UTC timezone (default)
** Get-JS7Order -RelativeDateTo +1d+TZ
* Relative date specified for the current timezone
** Get-JS7Order -RelativeDateTo +1d+TZ -Timezone (Get-Timezone)
* Relative date specified for a different timezone
** Get-JS7Order -RelativeDateTo +1h+TZ -Timezone (Get-Timezone -Id 'IST')

Default: Relative dates are converted to UTC.

.PARAMETER StateDateFrom
Optionally iimits results to orders that changed to the current status after the indicated date.

For specification of dates see -DateTo argument.

.PARAMETER RelativeStateDateFrom
Optionally iimits results to orders that changed to the current status after the indicated relative date.

For specification of relative dates see -RelativeDateTo argument.

.PARAMETER StateDateTo
Optionally iimits results to orders that changed to the current status before the indicated date.

For specification of dates see -DateTo argument.

.PARAMETER RelativeStateDateTo
Optionally iimits results to orders that changed to the current status before the indicated relative date.

For specification of relative dates see -RelativeDateTo argument.

.PARAMETER RegularExpression
Specifies that a regular expession is applied to Order IDs to filter results.
The Order ID includes the Order Name attribute that is specified when adding the order like this for an Order Name "myIdentifier":

    "#2020-11-19#P0000000498-myIdentifier"

A regular expression 'Identifier$' matches the above Order ID.

.PARAMETER Compact
Specifies that fewer attributes of orders are returned.

.PARAMETER Pending
Specifies that orders in a pending state should be returned. Such orders are not
assigned a start time.

.PARAMETER Scheduled
Specifies that orders in a scheduled state should be returned. Such orders are scheduled
for a later start time.

.PARAMETER InProgress
Specifies that orders in progress should be returned, i.e. orders that started but that
are currently not executing jobs.

.PARAMETER Running
Specifies that orders in a running state should be returned, i.e. orders for which a job is
currently being executed in a workflow.

.PARAMETER Suspended
Specifies that orders in suspended state should be returned. An order can be suspended
e.g. when being affected by the Suspend-JS7Order cmdlet or by the respective manual operation from the GUI.

.PARAMETER Prompting
Specifies that orders in a prompting state should be returned. Such orders are put on hold by a
prompt instruction in a workflow and require confirmation before proceeding with execution of the workflow.
For details see the Confirm-JS7Order cmdlet.

.PARAMETER Waiting
Specifies that orders in a setback state should be returned. Such orders make use of an interval
specified by a retry operation in the workflow for which they are repeated in case that a job fails.

.PARAMETER Failed
Specifies that orders in a failed state should be returned. Orders are considered to have failed
if a job in the workflow fails.

.PARAMETER Blocked
Specifies that orders should be returned that are blocked by a resource, e.g. if a job's task limit
is exceeded and the order has to wait for the next available task.

.PARAMETER IgnoreFailed
Specifies that errors relating to orders not being found are ignored.
An empty response will be returned.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
$orders = Get-JS7Order

Returns all orders available with a JS7 Controller.

.EXAMPLE
$orders = Get-JS7Order -Folder /some_path -Recursive

Returns all orders that are configured for workflows with the folder "/some_path"
including any sub-folders.

.EXAMPLE
$orders = Get-JS7Order -WorkflowPath /test/globals/workflow1

Returns the orders for workflow "workflow1" from the folder "/test/globals".

.EXAMPLE
$orders = Get-JS7Order -OrderId "#2020-11-19#P0000000498-orderSampleWorfklow2a"

Returns the order with the respective identifier.

.EXAMPLE
$orders = Get-JS7Order -RegularExpression 'sos$'

Returns orders with an Order ID that ends with the string "sos".

.EXAMPLE
$orders = Get-JS7Order -Suspended -Waiting

Returns any orders that have been suspended, e.g. after job failures, or
that are waiting to retry execution of a job after failure.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $StateDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeStateDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $StateDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeStateDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RegularExpression,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Compact,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Pending,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Scheduled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $InProgress,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Running,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Suspended,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Completed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Prompting,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Waiting,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Failed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Blocked,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $IgnoreFailed
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $returnOrders = @()
        $orderIds = @()
        $workflowIds = @()
        $folders = @()
        $states = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, OrderId=$OrderId"

        if ( !$Folder -and !$WorkflowPath -and !$OrderId -and !$RegularExpression)
        {
            throw "$($MyInvocation.MyCommand.Name): no folder, no workflow path, order id or regular expression is specified, use -Folder or -WorkflowPath or -OrderId or -RegularExpression"
        }

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

        if ( !$OrderId -and !$DateTo )
        {
            $DateTo = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(1).ToUniversalTime()
        }

        if ( $Pending -and 'PENDING' -notin $states )
        {
            $states += 'PENDING'
        }

        if ( $Scheduled -and 'SCHEDULED' -notin $states )
        {
            $states += 'SCHEDULED'
        }

        if ( $InProgress -and 'INPROGRESS' -notin $states )
        {
            $states += 'INPROGRESS'
        }

        if ( $Running -and 'RUNNING' -notin $states )
        {
            $states += 'RUNNING'
        }

        if ( $Suspended -and 'SUSPENDED' -notin $states )
        {
            $states += 'SUSPENDED'
        }

        if ( $Completed -and 'TERMINATED' -notin $states )
        {
            $states += 'TERMINATED'
        }

        if ( $Prompting -and 'PROMPTING' -notin $states )
        {
            $states += 'PROMPTING'
        }

        if ( $Waiting -and 'WAITING' -notin $states )
        {
            $states += 'WAITING'
        }

        if ( $Failed -and 'FAILED' -notin $states )
        {
            $states += 'FAILED'
        }

        if ( $Blocked -and 'BLOCKED' -notin $states )
        {
            $states += 'BLOCKED'
        }

        if ( $orderId )
        {
            $orderIds += $orderId
        }

        if ( $WorkflowPath -and $WorkflowPath -notin $workflowIds.path ) {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $objWorkflow

            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $objWorkflow
            }

            $workflowIds += $objWorkflow
        } elseif ( $Folder -and $Folder -notin $folders.folder ) {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $Compact )
        {
            Add-Member -Membertype NoteProperty -Name 'compact' -value $True -InputObject $body
        }

        if ( $orderIds.count )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body
        }

        if ( $workflowIds.count )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowIds' -value $workflowIds -InputObject $body
        }

        if ( $folders.count )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        # PowerShell/.NET does not create date output in the target timezone but with the local timezone only, let's work around this:
        $timezoneOffsetPrefix = if ( $Timezone.BaseUtcOffset.toString().startsWith( '-' ) ) { '-' } else { '+' }
        $timezoneOffsetHours = [Math]::Abs($Timezone.BaseUtcOffset.hours)

        if ( $Timezone.SupportsDaylightSavingTime -and $Timezone.IsDaylightSavingTime( (Get-Date) ) )
        {
            $timezoneOffsetHours += 1
        }

        [string] $timezoneOffset = "$($timezoneOffsetPrefix)$($timezoneOffsetHours.ToString().PadLeft( 2, '0' )):$($Timezone.BaseUtcOffset.Minutes.ToString().PadLeft( 2, '0' ))"

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
                Add-Member -Membertype NoteProperty -Name 'dateTo' -value (Get-Date (Get-Date $DateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
            }
        }

        if ( $StateDateFrom -or $RelativeStateDateFrom )
        {
            if ( $RelativeStateDateFrom )
            {
                if ( $RelativeStateDateFrom.endsWith( '+TZ' ) )
                {
                    $RelativeStateDateFrom = $RelativeStateDateFrom.Substring( 0, $RelativeStateDateFrom.length-3 ) + $timezoneOffset
                }

                Add-Member -Membertype NoteProperty -Name 'stateDateFrom' -value $RelativeStateDateFrom -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'stateDateFrom' -value (Get-Date (Get-Date $StateDateFrom).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
            }
        }

        if ( $StateDateTo -or $RelativeStateDateTo )
        {
            if ( $RelativeStateDateTo )
            {
                if ( $RelativeStateDateTo.endsWith( '+TZ' ) )
                {
                    $RelativeStateDateTo = $RelativeStateDateTo.Substring( 0, $RelativeStateDateTo.length-3 ) + $timezoneOffset
                }

                Add-Member -Membertype NoteProperty -Name 'stateDateTo' -value $RelativeStateDateTo -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'stateDateTo' -value (Get-Date (Get-Date $StateDateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
            }
        }

        if ( $RegularExpression )
        {
            Add-Member -Membertype NoteProperty -Name 'regex' -value $RegularExpression -InputObject $body
        }

        if ( $states.count )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/orders' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnOrders = ( $response.Content | ConvertFrom-JSON ).orders
        } elseif ( $response.StatusCode -eq 420 -and $IgnoreFailed ) {
            # no exception
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnOrders

        if ( $returnOrders.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnOrders.count) orders found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no orders found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
