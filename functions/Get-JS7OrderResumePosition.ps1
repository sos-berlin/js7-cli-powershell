function Get-JS7OrderResumePosition
{
<#
.SYNOPSIS
Returns workflow positions that can be used when resuming an order in a workflow

.DESCRIPTION
When adding an order to a workflow then a number of positions in the workflow can be used
as the starting position or as end positions. The cmdlet returns allowed positions for a given workflow.

The following REST Web Service API resources are used:

* /orders/resume/positions

.PARAMETER OrderId
Specifies the identifier of an order for which allowed positions for resumption will be returned.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller from which workflow positions will be returned.

.OUTPUTS
This cmdlet returns an array of workflow position objects.

.EXAMPLE
$positions = Get-JS7Order -WorkflowPath /ProductDemo/ParallelExecution/pdwFork -Suspended | Get-JS7OrderResumePosition

Returns the available positions of the given workflow that can be used when resuming a suspended order..

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $orderIds = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, WorkflowVersionId=$WorkflowVersionId"

        $orderIds += $orderId
    }

    End
    {
        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/orders/resume/positions' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnWorkflowPositions = ( $response.Content | ConvertFrom-Json ).positions
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnWorkflowPositions

        if ( $returnWorkflowPositionss.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnWorkflowPositions.count) workflow positions found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no workflows positions found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
