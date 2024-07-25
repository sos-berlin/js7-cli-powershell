function Set-JS7Order
{
<#
.SYNOPSIS
Transitions an existing order that will be continued or transferred

.DESCRIPTION
Transition an existing order for the JS7 Controller

The following REST Web Service API resources are used:

* /orders/continue
* /workflow/transition

.PARAMETER OrderId
Specifies the identifier of the order.

The argument is required if the -LetRun switch is used.

.PARAMETER WorkflowPath
Specifies the the path and name of a workflow for which orders should be transferred

The argument is required if the -Transfer switch is used.

.PARAMETER WorkflowVersionId
Deployed workflows are assigned a version identifier. The argument allows to select the
workflow that is assigned the specified version.

The argument is required if the -Transfer switch is used.

.PARAMETER LetRun
Continues orders in a waiting state.

The argument requires the -OrderId argument to be specified.

.PARAMETER Transfer
Transfers orders from a previous workflow version to the latest workflow version.

The argument requires the -WorkflowPath and -WorkflowVersionId arguments to be specified.
Related information is returned by the Get-JS7Workflow cmdlet.

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
This cmdlet accepts pipelined order objects that are e.g. returned from the Get-JS7Order cmdlet.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
Set-JS7Order -OrderId "#2020-11-23#T158058928-myTest03" -LetRun

Continues the order with Order ID "#2020-11-23#T158058928-myTest03".

.EXAMPLE
Get-JS7Order -Folder /some_folder -Waiting | Set-JS7Order -LetRun

Continues all waiting orders from the given workflow folder.

.EXAMPLE
Get-JS7Workflow -Folder /some_folder | Set-JS7Order -Transfer

Transfers orders from earlier versions of the workflow to the latest version of the workflow.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Transfer,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $LetRun,
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

        if ( !$Transfer -and !$LetRun )
        {
            throw "$($MyInvocation.MyCommand.Name): One of the actions -Transfer, -LetRun must be specified"
        }

        if ( $LetRun -and !$OrderId )
        {
            throw "$($MyInvocation.MyCommand.Name): argument -LetRun requires to specify -OrderId argument"
        }

        if ( $Transfer -and !$WorkflowPath )
        {
            throw "$($MyInvocation.MyCommand.Name): argument -Transfer requires to specify -WorkflowPath, -WorkflowVersionId arguments"
        }

        if ( ($WorkflowPath -and !$WorkflowVersionId) -or (!$WorkflowPath -and $WorkflowVersionId) )
        {
            throw "$($MyInvocation.MyCommand.Name): Both arguments -WorkflowPath and -WorkflowVersionId must be specified"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $orderIds = @()
    }

    Process
    {
        if ( $LetRun )
        {
            $orderIds += $OrderId
        }

        if ( $Transfer )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

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

            if ( $PSCmdlet.ShouldProcess( 'orders', '/workflow/transition' ) )
            {
                $workflowObj = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $workflowObj
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $workflowObj

                Add-Member -Membertype NoteProperty -Name 'workflowId' -value $workflowObj -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest '/workflow/transition' $requestBody

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

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): orders transferred"
            }
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

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

        if ( $LetRun )
        {
            if ( $PSCmdlet.ShouldProcess( 'orders', '/orders/continue' ) )
            {
                Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest '/orders/cancel' $requestBody

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

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($orderIds.count) orders continued"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
