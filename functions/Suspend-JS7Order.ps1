function Suspend-JS7Order
{
<#
.SYNOPSIS
Suspends an order in the JS7 Controller.

.DESCRIPTION
This cmdlet suspends an order in a JS7 Controller.
Suspended orders can later on be resumed by use of the Resume-JS7Order cmdlet.

If an order is in a running state, for example if a job is executed for the order then by default the
Agent will wait for that job to be completed before suspending the order. However, this behavior can be
changed by instructing the Agent to immediately kill running orders.

.PARAMETER OrderId
Specifies the identifier of the order.

.PARAMETER Kill
Specifies if the running task for the indicated order should be sent a SIGTERM signal (default, -Kill:$false) or a SIGKILLL signal (-Kill:$true).

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
This cmdlet accepts pipelined order objects that are e.g. returned from the Get-JS7Order cmdlet.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
Suspend-JS7Order -OrderId "#2020-11-19#P0000000498-orderSampleWorfklow2a"

Suspends the order with the given ID.

.EXAMPLE
Get-JS7Order | Suspend-JS7Order

Suspends all orders for all workflows.

.EXAMPLE
Get-JS7Order -WorkflowPath /some_workflow_path -Recursive | Suspend-JS7Order

Suspends orders that are available with the workflow "some_workflow_path" and any sub-folders.

.EXAMPLE
Get-JS7Order -WorkflowPath /test/samples/workflow1 | Suspend-JS7Order

Suspends all orders for the specified workflow.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Kill,
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

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $orders = @()
    }

    Process
    {
        $orders += $OrderId
    }

    End
    {
        if ( $orders.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orders -InputObject $body

            if ( $Kill )
            {
                Add-Member -Membertype NoteProperty -Name 'kill' -value $True -InputObject $body
            }

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
            $response = Invoke-JS7WebRequest '/orders/suspend' $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($orders.count) orders suspended"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no orders found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
