function Resume-JS7Order
{
<#
.SYNOPSIS
Resumes a number of orders in the JS7 Controller

.DESCRIPTION
This cmdlet resumes orders in a JS7 Controller.

.PARAMETER OrderId
Specifies the identifier of an order.

.PARAMETER Position
Specifies the position of an order in the workflow.

.PARAMETER Arguments
Specifies the arguments for the order. Arguments are created from a hashmap,
i.e. a list of names and values.

Example:
$orderArgs = @{ 'arg1' = 'value1'; 'arg2' = 'value2' }

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforece Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined order objects that are e.g. returned from a Get-JS7Order cmdlet.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
Resume-JS7Order -OrderId #2020-11-22#T072521128-Reporting

Resumes the order with the given ID.

.EXAMPLE
Get-JS7Order -Suspended | Resume-JS7Order

Resumes all suspended orders for all workflows.

.EXAMPLE
Get-JS7Order -Folder / | Resume-JS7Order

Resumes orders that are configured with the root folder 
without consideration of sub-folders.

.EXAMPLE
Get-JS7Order -Folder /some_path -Recursive | Resume-JS7Order

Resumes orders that are configured with the indicaed folder and any sub-folders.

.EXAMPLE
Get-JS7Order -WorkflowPath /test/globals/chain1 | Resume-JS7Order

Resumes orders for the specified workflow.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Position,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Arguments,
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

        $orders = @()
        $positions = @()
    }
    
    Process
    {
        $orders += $OrderId
        $positions += $Position
    }

    End
    {
        if ( $orders.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orders -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'position' -value $positions -InputObject $body

            if ( $Arguments )
            {
                Add-Member -Membertype NoteProperty -Name 'arguments' -value $Arguments -InputObject $body
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
            $response = Invoke-JS7WebRequest '/orders/resume' $requestBody
            
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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($orders.count) orders resumed"        
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no orders found"
        }
    
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
