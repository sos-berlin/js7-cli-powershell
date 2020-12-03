function Get-JS7Workflow
{
<#
.SYNOPSIS
Returns workflows from the JS7 inventory

.DESCRIPTION
Workflows are returned from JOC Cockpit - independent of their deployment status with specific Controller instances.
Workflows can be selected either by the folder of the workflow location including sub-folders or by an individual workflow path.

Resulting workflows can be forwarded to other cmdlets for pipelined bulk operations.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow that should be returned.

One of the parameters -Folder, -WorkflowPath or -RegularExpression has to be specified.

.PARAMETER WorkflowVersionId
Deployed workflows can be assigned a version identifier. This parameters allows to select 
workflows that are assigned the specified version.

.PARAMETER Folder
Optionally specifies the folder for which workflows should be returned. 

One of the parameters -Folder, -WorkflowPath or -RegularExpression has to be specified.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up. By default no sub-folders will be searched for workflows.

.PARAMETER RegularExpression
Limits result to workflow paths that correspond the given regular expression.

One of the parameters -Folder, -WorkflowPath or -RegularExpression has to be specified.

.PARAMETER Compact
Specifies that fewer attributes of a workflow are returned.

.OUTPUTS
This cmdlet returns an array of workflow objects.

.EXAMPLE
$workflows = Get-JS7Workflow

Returns all workflows.

.EXAMPLE
$workflows = Get-JS7Workflow -Folder /some_folder -Recursive

Returns all workflows that are configured with the specified folder
including any sub-folders.

.EXAMPLE
$workflows = Get-JS7Workflow -WorkflowPath /test/globals/workflow1

Returns the workflow "workflow1" from the folder "/test/globals".

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RegularExpression,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Compact
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        $workflowPaths = @()
        $folders = @()
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, RegularExpression=$RegularExpression"

        if ( !$Folder -and !$WorkflowPath -and !$RegularExpression )
        {
            throw "$($MyInvocation.MyCommand.Name): no folder,no workflow path and no regular expression specified, use -Folder, -WorkflowPath or -RegularExpression"
        }

        if ( $Folder -eq '/' -and !$WorkflowPath -and !$Recursive )
        {
            $Recursive = $True
        }
     
        if ( $WorkflowPath )
        {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $body

            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $body
            }

            $workflowPaths += $objWorkflow
        }

        if ( $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body

            if ( $Recursive )
            {
                Add-Member -Membertype NoteProperty -Name 'recursive' -value $True -InputObject $body
            }

            $folders += $objFolder
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        
        if ( $Compact )
        {
            Add-Member -Membertype NoteProperty -Name 'compact' -value $true -InputObject $body
        }

        if ( $workflowPaths )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowIds' -value $workflowPaths -InputObject $body
        }

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $RegularExpression )
        {
            Add-Member -Membertype NoteProperty -Name 'regex' -value $RegularExpression -InputObject $body            
        }
        
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/workflows' -Body $requestBody
        
        if ( $response.StatusCode -eq 200 )
        {
            $returnWorkflows += ( $response.Content | ConvertFrom-JSON ).workflows
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }        

        $returnWorkflows
    
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
