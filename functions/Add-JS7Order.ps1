function Add-JS7Order
{
<#
.SYNOPSIS
Adds an order to a workflow in the JS7 Controller

.DESCRIPTION
Creates a temporary order for execution with the specified workflow.

.PARAMETER OrderName
Specifies the name of an order. The JOC Cockpit web service will consider the order name
when creating unique order iDs from the pattern #<YYYY-MM-DD>#<qualifier><timestamp>-<order-name> 
such as with #2020-11-22#T072521128-Some_Order_Name.

* YYYY-MM-DD: Date for which the order is scheduled
* qualifier: one of T(emporary), P(lan), F(ile)
* timespan: time specified in milliseconds
* order-name: the value of the -OrderName parameter

.PARAMETER WorkflowPath
Specifies the path and name of a workflow for which an order should be added.

.PARAMETER Arguments
Specifies the arguments for the order. Arguments are created from a hashmap,
i.e. a list of names and values.

Example:
$orderArgs = @{ 'arg1' = 'value1'; 'arg2' = 'value2' }

.PARAMETER At
Specifies the point in time when the order should start. Values are added like this:

* now
** specifies that the order should start immediately
* now+1800
** specifies that the order should start with a delay of 1800 seconds, i.e. 30 minutes later.
* yyyy-mm-dd HH:MM[:SS]
** specifies that the order should start at the specified point in time.

.PARAMETER AtDate
Specifies the date when the order should start. The time zone is used from the date provided.

.PARAMETER Timezone
Specifies the time zone to be considered for the start time that is indicated with the -At parameter.
Without this parameter the time zone of the JS7 Controller is assumed. 

This parameter should be used if the JS7 Controller runs in a time zone different from the environment 
that makes use of this cmdlet.

Find the list of time zone names from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

.PARAMETER StartPosition
Specifies that the order should enter the workflow at the workflow node that
is assigend the specified position.

.PARAMETER EndPosition
Specifies that the order should leave the workflow at the workflow node that
is assigend the specified position.

.PARAMETER RunningNumber
This parameter is implicitely used when pipelining input to the cmdlet as e.g. with

    1..10 | Add-JS7Order -WorkflowPath /some_path/some_workflow

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, 
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This argument is not mandatory, however, JOC Cockpit can be configured 
to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined order objects that are e.g. returned from a Get-JobSchedulerOrder cmdlet.

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

Adds the indicated order for a later date that is specified for the "Europe/Berlin" time zone.

.EXAMPLE
$orderId = Add-JS7Order -WorkflowPath /sos/reporting/Reporting -At "now+3600" -Arguments @{'param1' = 'value1'; 'param2' = 'value2'}

Adds an order to the indicated workflow. The order will start one hour later and will use the
arguments as specified by the -Arguments parameter.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderName,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Arguments,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $At,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $AtDate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Timezone,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $EndState,
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
        $stopWatch = Start-StopWatch

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
            Add-Member -Membertype NoteProperty -Name 'orderName' -value $OrderName -InputObject $objOrder
        }

        if ( $scheduledFor )
        {
            Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value $scheduledFor -InputObject $objOrder
        }

        if ( $Timezone )
        {
            Add-Member -Membertype NoteProperty -Name 'timeZone' -value $Timezone -InputObject $objOrder
        }
<#
        if ( $StartPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'startPosition' -value $StartPosition -InputObject $objOrder
        }

        if ( $EndPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'endPosition' -value $EndPosition -InputObject $objOrder
        }
#>
        if ( $Arguments )
        {
            $objArgs = @()
            foreach( $argument in $Arguments.GetEnumerator() )
            {
                if ( $argument.key )
                {
                    $objArg = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'name' -value $argument.key -InputObject $objArg
                    Add-Member -Membertype NoteProperty -Name 'value' -value $argument.value -InputObject $objArg
                    $objArgs += $objArg
                }
            }

            if ( $objArgs.count )
            {
                Add-Member -Membertype NoteProperty -Name 'arguments' -value $objArgs -InputObject $objOrder
            }
        }

        $objOrders += $objOrder
        
        if ( $objOrders.count -ge $BatchSize )
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
            $response = Invoke-JS7WebRequest '/orders/add' $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $responseOrderIds = ( $response.Content | ConvertFrom-JSON ).orderIds
                
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
            $response = Invoke-JS7WebRequest '/orders/add' $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $responseOrderIds = ( $response.Content | ConvertFrom-JSON ).orderIds
                
                if ( !$responseOrderIds )
                {
                    throw "could not add orders: $($requestResult.message)"
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            $returnOrderIds += $responseOrderIds            
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnOrderIds.count) orders added"                
        }

        $returnOrderIds

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
