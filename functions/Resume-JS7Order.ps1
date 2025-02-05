function Resume-JS7Order
{
<#
.SYNOPSIS
Resumes suspended or failed orders in a JS7 Controller

.DESCRIPTION
This cmdlet resumes orders that are suspended or failed in a JS7 Controller.

The following REST Web Service API resources are used:

* /orders/resume

.PARAMETER OrderId
Specifies the identifier of an order.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which orders should be resumed.

One of the parameters -Folder, -WorkflowPath or -OrderId has to be specified if no pipelined order objects are provided.

.PARAMETER WorkflowVersionId
Deployed workflows are assigned a version identifier. The argument allows to select the
workflow that is available with the specified version.

.PARAMETER Folder
Optionally specifies the folder of workflows for which orders should be resumed.

One of the parameters -Folder, -OrderId, -Folders or -State has to be specified.

.PARAMETER Recursive
When used with the -Folder parameter specifies that any sub-folders should be looked up.
By default no sub-folders will be searched for workflows.

.PARAMETER Position
Specifies the position in the workflow for which the order should be resumed,
i.e. the order will continue to execute with the instruction indicated by the position.

The position is specified as an array, e.g. @(2, "then", 0) which translates to the
3rd instruction of the workflow, that is an If-Instruction, and the first instruction in the "then" branch.

.PARAMETER Arguments
Specifies the arguments for the order. Arguments are created from a hashmap,
i.e. a list of names and values.

Example:
$orderArgs = @{ 'arg1' = 'value1'; 'arg2' = 'value2' }

.PARAMETER State
Limits the scope of orders to be resumed to the following order states:

* PENDING
* SCHEDULED
* INPROGRESS
* RUNNING
* SUSPENDED
* WAITING
* PROMPTING
* FAILED
* BLOCKED

.PARAMETER Force
Specifies that jobs marked as non-restartable will be forced to restart on resumption of the order.

.PARAMETER FromCurrentBlock
Specifies that orders should be resumed from the begin of the current block instruction in which they are suspended or failed.

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
This cmdlet returns no output.

.EXAMPLE
Resume-JS7Order -OrderId "#2020-11-22#T072521128-Reporting"

Resumes the order with the given ID from its current position.

.EXAMPLE
Resume-JS7Order -OrderId "#2020-11-22#T072521128-Reporting" -Position @(2)

Resumes the order with the given ID from the 3rd instruction in the workflow.

.EXAMPLE
Get-JS7Order -Suspended | Resume-JS7Order

Resumes all suspended orders for any workflows.

.EXAMPLE
Resume-JS7Order -State 'SUSPENDED','FAILED' -Folder /

Resumes orders that are configured with the root folder
without consideration of sub-folders.

.EXAMPLE
Resume-JS7Order -State 'SUSPENDED','FAILED' -Folder /some_path -Recursive

Resumes suspended and failed orders that are configured with the indicated folder and any sub-folders.

.EXAMPLE
Get-JS7Order -WorkflowPath /test/samples/workflow1 -Suspended | Resume-JS7Order

Resumes suspended orders for the specified workflow.

.EXAMPLE
$orders = Get-JS7Order -WorkflowPath /ProductDemo/ParallelExecution/pdwFork -Suspended
$positions = $orders | Get-JS7OrderResumePosition
$orders | Resume-JS7Order -Position $positions[2].position

Retrieves suspended orders and possible positions to resume. The third (index: 2) position is used to resume the order.
.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [object[]] $Position,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Arguments,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [ValidateSet('PENDING','SCHEDULED','INPROGRESS','RUNNING','SUSPENDED','WAITING','PROMPTING','FAILED','BLOCKED',IgnoreCase = $False)]
    [string[]] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Force,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $FromCurrentBlock,
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
        $workflows = @()
        $folders = @()
        $states = @()
    }

    Process
    {
        if ( $OrderId )
        {
            $orders += $OrderId
        }

        if ( $WorkflowPath )
        {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Workflow -InputObject $objWorkflow

            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'version' -value $WorkflowVersionId -InputObject $objWorkflow
            }

            $workflows += $objWorkflow
        }

        if ( $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder

            if ( $Recursive )
            {
                Add-Member -Membertype NoteProperty -Name 'recursive' -value $True -InputObject $objFolder
            }

            $folders += $objFolder
        }

        if ( $State )
        {
            $states += $State
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'force' -value ($Force -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'fromCurrentBlock' -value ($FromCurrentBlock -eq $True) -InputObject $body

        if ( $orders.count )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orders -InputObject $body
        }

        if ( $workflows.count )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowIds' -value $workflows -InputObject $body
        }

        if ( ($orders.count -eq 1) -and $Position )
        {
            Add-Member -Membertype NoteProperty -Name 'position' -value $Position -InputObject $body
        }

        if ( ($orders.count -eq 1) -and $Arguments )
        {
            Add-Member -Membertype NoteProperty -Name 'arguments' -value $Arguments -InputObject $body
        }

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
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
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult.ok )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
