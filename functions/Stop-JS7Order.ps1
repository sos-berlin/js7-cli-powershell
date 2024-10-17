function Stop-JS7Order
{
<#
.SYNOPSIS
Cancels an order in the JS7 Controller

.DESCRIPTION
This cmdlet cancels order in a JS7 Controller.

If an order is in a running state, for example if a job is executed for the order then by default the
Agent will wait for the job to be completed before cancelling the order. This behavior can be
changed by instructing the Agent to foribly terminate running jobs.

Orders are cancelled and removed by

* a pipelined object, e.g. the output of the Get-JS7Order cmdlet
* specifying an individual order with the -OrderId parameter.

The following REST Web Service API resources are used:

* /orders/cancel

.PARAMETER OrderId
Specifies the identifier of an order.

.PARAMETER Force
Specifies if the running task for the indicated order should be sent a SIGTERM signal (default, -Force:$false) or a SIGKILLL signal (-Force:$true).

.PARAMETER Deep
Specifies that child orders in a Fork-Join Instruction or ForkList-Join Instruction will be subject to cancellation.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This parameter is not mandatory. However, the JOC Cockpit can be configured to require Audit Log comments for all interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined order objects that are e.g. returned from a Get-JS7Order cmdlet.

.OUTPUTS
This cmdlet returns an array of removed order objects.

.EXAMPLE
Stop-JS7Order -OrderId "#2020-11-22#T072521128-Reporting" -Kill

Cancels the order by sending a SIGKILL signal to the order's running task.

.EXAMPLE
Get-JS7Order -WorkflowPath /some_path/some_workflow | Stop-JS7Order

Retrieves and cancels all orders for the given workflow. Running tasks can complete.

.EXAMPLE
Get-JS7Order -Folder /sos -Recursive | Stop-JS7Order -Kill

Retrieves and cancels all orders from the indicated folder including any sub-folders.
Running tasks are killed.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Alias('Kill')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Force,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Deep,
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
        $orders += $orderId
    }

    End
    {
        if ( $orders.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orders -InputObject $body

            if ( $Force )
            {
                Add-Member -Membertype NoteProperty -Name 'kill' -value $True -InputObject $body
            }

            if ( $Deep )
            {
                Add-Member -Membertype NoteProperty -Name 'deep' -value $True -InputObject $body
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

            if ( $PSCmdlet.ShouldProcess( 'orders', '/orders/cancel' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/orders/cancel' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $requestResult = ( $response.Content | ConvertFrom-Json )

                    if ( !$requestResult.ok )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($orders.count) orders cancelled"
            }
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no orders found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
