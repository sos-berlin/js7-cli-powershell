function Add-JS7Order
{
<#
.SYNOPSIS
Adds an order to a workflow in a JS7 Controller

.DESCRIPTION
Creates a temporary order for execution with the specified workflow.

The following REST Web Service API resources are used:

* /orders/add

.PARAMETER WorkflowPath
Specifies the path and/or name of a workflow for which an order should be added.

.PARAMETER OrderName
Specifies the name of an order. The JOC Cockpit web service will consider the order name
when creating unique Order IDs with the pattern #<YYYY-MM-DD>#<qualifier><timestamp>-<order-name>
such as #2020-11-22#T072521128-Some_Order_Name.

* YYYY-MM-DD: Date for which the order is scheduled
* qualifier: one of T(emporary), P(lan), F(ile), created by AD(D) Order Instruction
* timespan: time specified in milliseconds
* order-name: the value of the -OrderName parameter

.PARAMETER Variables
Specifies the variables for the order. Variables are created from a hashmap,
i.e. a list of names and values. Values have to be specified according to the
variables declaration of the workflow and include use of the data types:

* string: $orderVariables = @{ 'arg1' = 'value1' }
* number: $orderVariables = @{ 'arg2' = 3.14 }
* boolean: $orderVariables = @{ 'arg3' = $true }

Example:
$orderVariables = @{ 'var1' = 'value1'; 'var2' = 3.14; 'var3' = $true }

Consider that a workflow can declare required variables that have to be added to an order.

.PARAMETER At
Specifies the point in time when the order should start. Values are added like this:

* now
** specifies that the order should start immediately
* now+1800
** specifies that the order should start with a delay of 1800 seconds, i.e. 30 minutes later.
* yyyy-mm-dd HH:MM[:SS]
** specifies that the order should start at the specified point in time.
* never
** specifies that the order is added without a desired start time. Users have to manually modify the start time
of such orders to make them start.

.PARAMETER AtDate
Specifies the date when the order should start. The time zone is used from the date provided.

.PARAMETER Timezone
Specifies the time zone to be considered for the start time that is indicated with the -At parameter.
Without this parameter the time zone of the JS7 Controller is assumed.

This parameter should be used if the JS7 Controller runs in a time zone different from the environment
that makes use of this cmdlet.

Find the list of time zone names from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

.PARAMETER BlockPostion
Specifies that the order should start execution within the block instruction identified by the label indicated from the argument value.

For use with branches of Fork Instructions consider to specify <fork-label>+<branch-label>, for example
if a Fork Instruction is labelled "myFork" and a branch is labelled "linux1" then the value of the -BlockPosition argument is "myFork+linux1".

To start at a later position inside a block instruction use the -StartPosition argument.

.PARAMETER StartPosition
Specifies the label of an instruction in the workflow that the order will be started for.

The top-level instructions in a workflow are allowed start positions. If an instruction inside some block Instruction
should be used as the start position, then the -BlockPosition argument can be used to specify the label of the block
and the -StartPosition argument can be used to specify the label of an instruction inside the block.

.PARAMETER EndPositions
Specifies the labels of instructions in the workflow at which the order will leave the workflow.
The order will not execute the related instruction.

.PARAMETER ForceJobAdmission
Specifies that job admission times should not be considered. The order will execute all jobs in the workflow
without waiting for specified admission times.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller to which the order is added.

.PARAMETER BatchSize
As this cmdlet accepts pipelined input a larger number of orders can be added at the same time.
This is particularly true if the Invoke-JS7TestRun cmdlet is used.

Larger numbers of orders are split into individual calls to the REST API according to the batch size.
This is required as larger batches could exceed the size of HTTP post requests that frequently
is limited to 4MB if an HTTP proxy is used.

.PARAMETER RunningNumber
This parameter is implicitly used when pipelining input to the cmdlet as e.g. with

    1..10 | Add-JS7Order -WorkflowPath /some_path/some_workflow

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention,
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This argument is not mandatory, however, JOC Cockpit can be configured
to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined order objects that are e.g. returned from the Get-JS7Order cmdlet.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
Add-JS7Order -WorkflowPath /sos/reporting/Reporting -OrderName Test

Adds an order to the indicated workflow.

.EXAMPLE
$orderIds = 1..10 | Add-JS7Order -WorkflowPath /sos/reporting/Reporting -OrderName Test

Adds 10 orders to the indicated workflow.

.EXAMPLE
$orderId = Add-JS7Order -OrderName Test -WorkflowPath /sos/reporting/Reporting -At "now+1800"

Adds the indicated order for a start time 30 minutes (1800 seconds) from now.

.EXAMPLE
$orderId = Add-JS7Order -OrderName Test -WorkflowPath /sos/reporting/Reporting -At "2038-01-01 00:00:00" -Timezone "Europe/Berlin"

Adds andorder for a later date that is specified for the "Europe/Berlin" time zone.

.EXAMPLE
$orderId = Add-JS7Order -WorkflowPath /sos/reporting/Reporting -At "now+3600" -Variables @{'var1'='value1'; 'var2'=3.14; 'var3'=$true}

Adds an order to the indicated workflow. The order will start one hour later and will use the
variables as specified by the -Variables parameter.

.EXAMPLE
$orderId = Add-JS7Order -WorkflowPath /ProductDemo/ParallelExecution/pdwFork -StartPosition "job2"

Adds an order to the workflow position labelled "job2" of the indicated workflow.

.EXAMPLE
$orderId = Add-JS7Order -WorkflowPath /ProductDemo/ParallelExecution/pdwFork -EndPositions "job3","job4"

Adds an order for two possible end positions with the labels "job3" and "job4" of the indicated workflow.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Variables,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $At,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $AtDate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Timezone,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $BlockPosition,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $StartPosition,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $EndPositions,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Tag,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForceJobAdmission,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $BatchSize = 100,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [int] $RunningNumber,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( $At -and $AtDate )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -At and -AtDate can be used"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $objOrders = @()
        $scheduledFor = $null;
        $returnOrderIds = @()
    }

    Process
    {
        if ( $AtDate -ge (Get-Date) )
        {
            $scheduledFor = ( Get-Date (Get-Date $AtDate).ToUniversalTime() -Format 'yyyy-MM-dd HH:mm:ss' )
            $Timezone = 'UTC'
        } elseif ( !$Timezone -and $At -match "^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01]) (\d{2}):(\d{2})(:(\d{2}))?$" ) {
            $scheduledFor = ( Get-Date (Get-Date $At).ToUniversalTime() -Format 'yyyy-MM-dd HH:mm:ss' )
            $Timezone = 'UTC'
        } elseif ( $At ) {
            $scheduledFor = $At
        }

        $objOrder = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $WorkflowPath -InputObject $objOrder

        if ( $OrderName )
        {
            if ( $RunningNumber )
            {
                Add-Member -Membertype NoteProperty -Name 'orderName' -value "$($OrderName)-$($RunningNumber)" -InputObject $objOrder
            } else {
                Add-Member -Membertype NoteProperty -Name 'orderName' -value $OrderName -InputObject $objOrder
            }
        } elseif ( $RunningNumber ) {
            Add-Member -Membertype NoteProperty -Name 'orderName' -value $RunningNumber -InputObject $objOrder
        }

        if ( $scheduledFor )
        {
            Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value $scheduledFor -InputObject $objOrder
        }

        if ( $Timezone )
        {
            Add-Member -Membertype NoteProperty -Name 'timeZone' -value $Timezone -InputObject $objOrder
        }

        if ( $StartPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'startPosition' -value $StartPosition -InputObject $objOrder
        }

        if ( $BlockPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'blockPosition' -value $BlockPosition -InputObject $objOrder
        }

        if ( $EndPositions.count )
        {
            Add-Member -Membertype NoteProperty -Name 'endPositions' -value $EndPositions -InputObject $objOrder
        }

        if ( $ForceJobAdmission )
        {
            Add-Member -Membertype NoteProperty -Name 'forceJobAdmission' -value ($ForceJobAdmission -eq $True) -InputObject $objOrder
        }

        if ( $Variables )
        {
            Add-Member -Membertype NoteProperty -Name 'arguments' -value $Variables -InputObject $objOrder
        }

        if ( $Tag )
        {
            Add-Member -Membertype NoteProperty -Name 'tags' -value ($Tag) -InputObject $objOrder
        }

        $objOrders += $objOrder

        if ( $objOrders.count -ge $BatchSize )
        {
            $body = New-Object PSObject

            if ( $ControllerId )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            }

            Add-Member -Membertype NoteProperty -Name 'orders' -value $objOrders -InputObject $body

            if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
            {
                $objAuditLog = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

                if ( $AuditTimeSpent )
                {
                    Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
                }

                if ( $AuditTicketLink )
                {
                    Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
                }

                Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
            }

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/orders/add' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $responseOrderIds = ( $response.Content | ConvertFrom-Json ).orderIds

                if ( !$responseOrderIds )
                {
                    throw "could not add orders: $($requestResult.message)"
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            $returnOrderIds += $responseOrderIds
            $objOrders = @()
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnOrderIds.count) orders added"
        }

        Write-Debug ".. $($MyInvocation.MyCommand.Name): running number for order: $RunningNumber"
    }

    End
    {
        if ( $objOrders.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'orders' -value $objOrders -InputObject $body

            if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
            {
                $objAuditLog = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

                if ( $AuditTimeSpent )
                {
                    Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
                }

                if ( $AuditTicketLink )
                {
                    Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
                }

                Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
            }

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/orders/add' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $responseOrderIds = ( $response.Content | ConvertFrom-Json ).orderIds

                if ( !$responseOrderIds )
                {
                    throw "could not add orders: $($response.message)"
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            $returnOrderIds += $responseOrderIds
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnOrderIds.count) orders added"
        }

        $returnOrderIds

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
