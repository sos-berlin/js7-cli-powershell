function Remove-JS7TerminatedOrder
{
<#
.SYNOPSIS
Removes an order that has terminated in a workflow either with a cancelled or finished state.

.DESCRIPTION
Orders in a worklfow by default are automatically removed upon termination. However, it is possible
to make orders remain in a workflow after termination. Such orders are either in a cancelled state
or in a finished state.

The cmdlet causes orders to be removed after termination.

.PARAMETER OrderId
Specifies the identification of an order.

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
Remmove-JS7TerminatedOrder -Id "#2021-01-19#T086350577-ap27"

Causes the indicated order to be removed upon termination of its workflow.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
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

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $orderIds = @()
    }
    
    Process
    {
        $orderIds += $OrderId        
    }

    End
    {
        if ( $orderIds.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'orderIdss' -value $orderIds -InputObject $body
    
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
        
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/orders/remove_when_terminated' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $ok = ( $response.Content | ConvertFrom-JSON ).ok
                    
                    if ( !$ok )
                    {
                        throw "could not add orders: $($requestResult.message)"
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnOrderIds.count) orders added"                
        }

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
