function Get-JS7Order
{
<#
.SYNOPSIS
Returns orders from the JS7 Controller

.DESCRIPTION
Orders are selected from the JS7 Controller

* by the folder of the order location including sub-folders,
* by the workflow that is assigned to an order,
* by an individual order ID.

Resulting orders can be forwarded to other cmdlets for pipelined bulk operations.

.PARAMETER OrderId
Optionally specifies the identifier of an order that should be returned.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which orders should be returned.

One of the parameters -Folder, -WorkflowPath or -OrderId has to be specified if no pipelined order objects are provided.

.PARAMETER WorkflowVersionId
Deployed workflows can be assigned a version identifier. This parameters allows to select
workflows that are assigned the specified version.

.PARAMETER Folder
Optionally specifies the folder with workflows for which orders should be returned.

One of the parameters -Folder, -WorkflowPath or -OrderId has to be specified if no pipelined order objects are provided.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be searched for orders.

.PARAMETER DateTo
Specifies the date until which orders should be returned.
Consider that a UTC date has to be provided.

Default should no order ID be provided: End of the current day as a UTC date

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
for the timezone that is specified with the -Timezone parameter.

.PARAMETER Timezone
Specifies the timezone to which a relative date specified with the -RelativeDateTo parameter should be converted.
A timezone can e.g. be specified like this:

  Get-JS7Order -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Get-JS7Order -Timezone (Get-Timezone)

Default: Dates are converted to UTC.

.PARAMETER RegularExpression
Specifies that a regular expession is applied to the order IDs to filter results.

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
e.g. when being affected by the Suspend-JobSchedulerOrder cmdlet or the respective manual operation from the GUI.

.PARAMETER Prompting
Specifies that orders in a prompting state should be returned. Such orders are put on hold by a
prompt instruction in a workflow and require confirmation to futher proceed execution of the workflow. 
For details see the Confirm-JS7Order cmddlet.

.PARAMETER Waiting
Specifies that orders in a setback state should be returned. Such orders make use of an interval
specified by a retry operation in the workflow for which they are repeated in case that a job fails.

.PARAMETER Failed
Specifies that orders in a failed state should be returned. Orders are considered being failed
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
$orders = Get-JS7Order -Suspended -Waiting

Returns any orders that have been suspended, e.g. after job failures, or
that are waiting to retry execution of a job after failure.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
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

        if ( $Pending )
        {
            $states += 'PENDING'
        }

        if ( $Scheduled )
        {
            $states += 'SCHEDULED'
        }

        if ( $InProgress )
        {
            $states += 'INPROGRESS'
        }

        if ( $Running )
        {
            $states += 'RUNNING'
        }

        if ( $Suspended )
        {
            $states += 'SUSPENDED'
        }

        if ( $Prompting )
        {
            $states += 'PROMPTING'
        }

        if ( $Waiting )
        {
            $states += 'WAITING'
        }

        if ( $Failed )
        {
            $states += 'FAILED'
        }

        if ( $Blocked )
        {
            $states += 'BLOCKED'
        }


        if ( $OrderId )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            if ( $Compact )
            {
                Add-Member -Membertype NoteProperty -Name 'compact' -value $True -InputObject $body
            }

            Add-Member -Membertype NoteProperty -Name 'orderId' -value $orderId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'suppressNotExistException' -value $False -InputObject $body

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/order' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $returnOrders = ( $response.Content | ConvertFrom-JSON )
            } elseif ( $response.StatusCode -eq 420 -and $IgnoreFailed ) {
                # exception not forwarded
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            $returnOrders
        } elseif ( $WorkflowPath ) {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $objWorkflow

            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $objWorkflow
            }

            $workflowIds += $objWorkflow
        } elseif ( $Folder ) {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }
    }

    End
    {
        if ( !$OrderId )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            if ( $Compact )
            {
                Add-Member -Membertype NoteProperty -Name 'compact' -value $True -InputObject $body
            }

            if ( $workflowIds.count )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowIds' -value $workflowIds -InputObject $body
            }

            if ( $folders.count )
            {
                Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
            }

            if ( $DateTo -or $RelativeDateTo )
            {
                if ( $RelativeDateTo )
                {
                    if ( $RelativeDateTo.endsWith( '+TZ' ) )
                    {
                        # PowerShell/.NET does not create date output in the target timezone but with the local timezone only, let's work around this:
                        $timezoneOffsetPrefix = if ( $Timezone.BaseUtcOffset.toString().startsWith( '-' ) ) { '-' } else { '+' }
                        $timezoneOffsetHours = [Math]::Abs($Timezone.BaseUtcOffset.hours)

                        if ( $Timezone.SupportsDaylightSavingTime -and $Timezone.IsDaylightSavingTime( (Get-Date) ) )
                        {
                            $timezoneOffsetHours += 1
                        }

                        [string] $timezoneOffset = "$($timezoneOffsetPrefix)$($timezoneOffsetHours.ToString().PadLeft( 2, '0' )):$($Timezone.BaseUtcOffset.Minutes.ToString().PadLeft( 2, '0' ))"

                        $RelativeDateTo = $RelativeDateTo.Substring( 0, $RelativeDateTo.length-3 ) + $timezoneOffset
                    }

                    Add-Member -Membertype NoteProperty -Name 'dateTo' -value $RelativeDateTo -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'dateTo' -value ( Get-Date (Get-Date $DateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
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
        }

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
