function Get-JS7OrderAddPosition
{
<#
.SYNOPSIS
Returns workflow positions that can be used when adding an order to a workflow

.DESCRIPTION
When adding an order to a workflow then a number of positions in the workflow can be used
as the starting position or as end positions. The cmdlet returns allowed positions for a given workflow.

The following REST Web Service API resources are used:

* /orders/add/positions

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which positions will be returned.

.PARAMETER WorkflowVersionId
Deployed workflows are assigned a version identifier. This parameter allows selection of
workflows that are assigned the specified version.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller from which workflow positions will be returned.

.OUTPUTS
This cmdlet returns an array of workflow position objects.

.EXAMPLE
$positions = Get-JS7OrderAddPosition -WorkflowPath /ProductDemo/ParallelExecution/pdwFork

Returns the available positions of the given workflow that can be used as the start position and as end positions when adding orders.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Alias('VersionId')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, WorkflowVersionId=$WorkflowVersionId"

        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $objWorkflow

            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $objWorkflow
            }

        Add-Member -Membertype NoteProperty -Name 'workflowId' -value $objWorkflow -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/orders/add/positions' -Body $requestBody

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
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
