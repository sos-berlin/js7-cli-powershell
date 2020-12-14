function Start-JS7Order
{
<#
.SYNOPSIS
Starts an existing order for the JS7 Controller

.DESCRIPTION
Start an existing order for the JS7 Controller and optionally adjust the start time and arguments.

.PARAMETER OrderId
Specifies the identifier of the order.

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
Specifies the time zone to be considered for the start time that is indicated with the -At argument.
Without this argument the time zone of the JS7 Controller is assumed. 

This argument should be used if the JS7 Controller runs in a time zone different to the environment 
that makes use of this cmdlet.

Find the list of time zone names from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

.PARAMETER StartPosition
Specifies that the order should enter the workflow at the workflow node that
is assigend the specified position.

.PARAMETER EndPosition
Specifies that the order should leave the workflow at the workflow node that
is assigend the specified position.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined order objects that are e.g. returned from a Get-JobSchedulerOrder cmdlet.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
Start-JS7Order -OrderId "#2020-11-23#T158058928-myTest03"

Starts the order with order ID "#2020-11-23#T158058928-myTest03".

.EXAMPLE
Start-JS7Order -OrderId "#2020-11-23#T158058928-myTest03" -At "now+1800"

Starts the specified order for a start time 30 minutes (1800 seconds) from now.

.EXAMPLE
Start-JS7Order -OrderId "#2020-11-23#T158058928-myTest03" -At "2038-01-01 00:00:00" -Timezone "Europe/Berlin"

Starts the indicated order for a later date that is specified for the "Europe/Berlin" time zone.

.EXAMPLE
Start-JS7Order -OrderId "#2020-11-23#T158058928-myTest03" -At "now+3600" -Arguments @{'arg1' = 'value1'; 'arg2' = 'value2'}

Starts the order with the specified order ID. The order will start one hour later and will use the
arguments from the specified hashmap.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Arguments,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $At = 'now',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $AtDate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Timezone,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $StartPosition,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $EndPosition,
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
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -At or -AtDate can be used"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $orderIds = @()
        $objOrders = @()
        $scheduledFor = $null;
    }
    
    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        
        Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $body            
        Add-Member -Membertype NoteProperty -Name 'suppressNotExistException' -value $True -InputObject $body            

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/order' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $returnOrder = ( $response.Content | ConvertFrom-JSON )

            if ( !$returnOrder.orderId )
            {
                throw "$($MyInvocation.MyCommand.Name): could not find order ID: $OrderId"
            }

            if ( $returnOrder.state._text -ne 'PENDING' )
            {
                throw "$($MyInvocation.MyCommand.Name): order already started and is in $($returnOrder.state._text) state: $OrderId"                
            }

        } else {
            throw ( $response | Format-List -Force | Out-String )
        }
    

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
        Add-Member -Membertype NoteProperty -Name 'orderName' -value $OrderId.Substring( $OrderId.LastIndexOf( '-' )+1 ) -InputObject $objOrder
        Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $returnOrder.workflowId.path -InputObject $objOrder

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
            $objArguments = @()
            foreach( $argument in $Arguments.GetEnumerator() )
            {
                $objArgument = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'name' -value $argument.key -InputObject $objArgument
                Add-Member -Membertype NoteProperty -Name 'value' -value $argument.value -InputObject $objArgument
                $objArguments += $objArgument
            }

            if ( $objArguments.count )
            {
                Add-Member -Membertype NoteProperty -Name 'arguments' -value $objArguments -InputObject $objOrder
            }
        } elseif ( $returnOrder.arguments ) {
            Add-Member -Membertype NoteProperty -Name 'arguments' -value $returnOrder.arguments -InputObject $objOrder            
        }

        $objOrders += $objOrder
        $orderIds += $OrderId
    }

    End
    {
        if ( $objOrders.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body

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
            $response = Invoke-JS7WebRequest '/orders/cancel' $requestBody
            
            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-JSON )
                
                if ( !$requestResult.ok )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }        
            
            
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
                $returnOrderIds = ( $response.Content | ConvertFrom-JSON ).orderIds
                
                if ( !$returnOrderIds )
                {
                    throw "could not add orders: $($requestResult.message)"
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        
            $returnOrderIds

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($objOrders.count) orders started"                
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no orders found"                
        }

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
