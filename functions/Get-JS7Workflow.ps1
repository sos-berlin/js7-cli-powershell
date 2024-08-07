function Get-JS7Workflow
{
<#
.SYNOPSIS
Returns workflows from the JOC Cockpit inventory

.DESCRIPTION
Workflows are returned from JOC Cockpit, independently of their deployment status with specific Controller instances.
Workflows can be selected by the folder of the workflow location including sub-folders or by the workflow name or path.

Resulting workflows can be forwarded to other cmdlets for pipelined bulk operations.

The following REST Web Service API resources are used:

* /workflows

.PARAMETER WorkflowPath
Optionally specifies the path or name of a workflow that should be returned.

.PARAMETER WorkflowVersionId
Deployed workflows are assigned a version identifier. This parameter allows selection of
a workflow that is assigned the specified version identifier.

.PARAMETER Folder
Optionally specifies the folder for which workflows should be returned.

.PARAMETER Recursive
When used with the -Folder parameter specifies that any sub-folders should be looked up.
By default no sub-folders will be searched for workflows.

.PARAMETER Suspended
Filters workflows to be returned that are in suspended state. Such workflows are frozen.

.PARAMETER Outstanding
Filters workflows to be returned that are in outstanding state. Such workflows are not confirmed by Agents to be successfully suspended or resumed.

.PARAMETER Synchronized
Filters workflows to be returned that are in sync between JOC Cockpit inventory and Controller.

.PARAMETER NotSynchronized
Filters workflows to be returned that are not in sync between JOC Cockpit inventory and Controller.

.PARAMETER SkippedInstruction
Filters workflows to be returned that include skipped instructions.

.PARAMETER StoppedInstruction
Filters workflows to be returned that include stopped instructions.

.PARAMETER Tag
Filters workflows by a list of tags.

If more than one tag is specified then they are separated by comma.

.PARAMETER AgentName
Filters workflows by Agents that are assigned to jobs in the workflow.

If more than one Agent Name is specified, then they are separated by comma.

.PARAMETER RegularExpression
Limits results to workflow paths that correspond to the given regular expression.

.PARAMETER Compact
Specifies that fewer attributes of a workflow are returned.

.OUTPUTS
This cmdlet returns an array of workflow objects.

.EXAMPLE
$workflows = Get-JS7Workflow

Returns all workflows.

.EXAMPLE
$workflows = Get-JS7Workflow -Folder /some_folder -Recursive

Returns workflows that are available with the specified folder including any sub-folders.

.EXAMPLE
$workflows = Get-JS7Workflow -WorkflowPath workflow1

Returns the workflow "workflow1" independently from its folder location.

.EXAMPLE
$workflows = Get-JS7Workflow -Suspended

Returns workflows that are in suspended state.

.EXAMPLE
$workflows = Get-JS7Workflow -Tag ProductDemo,ScheduledExecution

Returns workflows that hold one or more of the tags specified.

.EXAMPLE
$workflows = Get-JS7Workflow -AgentName primaryAgent,secondaryAgent

Returns workflows that hold jobs assigned one of the Agents specified.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Suspended,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Outstanding,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Synchronized,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NotSynchronized,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $SkippedInstruction,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $StoppedInstruction,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Tag,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RegularExpression,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Compact
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $workflowPaths = @()
        $folders = @()
        $states = @()
        $instructionStates = @()
        $tags = @()
        $agentNames = @()
        $returnWorkflows = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, RegularExpression=$RegularExpression"

        if ( $Folder -and $Folder -ne '/' )
        {
            if ( !$Folder.StartsWith( '/' ) )
            {
                $Folder = '/' + $Folder
            }

            if ( $Folder.EndsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }

        if ( $Folder -eq '/' -and !$WorkflowPath -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $WorkflowPath )
        {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $objWorkflow

            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $objWorkflow
            }

            $workflowPaths += $objWorkflow
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

        if ( $Suspended )
        {
            $states += 'SUSPENDED'
        }

        if ( $Outstanding )
        {
            $states += 'OUTSTANDING'
        }

        if ( $Synchronized )
        {
            $states += 'IN_SYNC'
        }

        if ( $NotSynchronized )
        {
            $states += 'NOT_IN_SYNC'
        }

        if ( $SkippedInstruction )
        {
            $instructionStates += 'SKIPPED'
        }

        if ( $StoppedInstruction )
        {
            $instructionStates += 'STOPPED'
        }

        if ( $Tag )
        {
            $tags += $Tag
        }

        if ( $AgentName )
        {
            $agentNames += $AgentName
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

        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        if ( $instructionStates )
        {
            Add-Member -Membertype NoteProperty -Name 'instructionStates' -value $instructionStates -InputObject $body
        }

        if ( $tags )
        {
            Add-Member -Membertype NoteProperty -Name 'tags' -value $tags -InputObject $body
        }

        if ( $agentNames )
        {
            Add-Member -Membertype NoteProperty -Name 'agentNames' -value $agentNames -InputObject $body
        }

        if ( $RegularExpression )
        {
            Add-Member -Membertype NoteProperty -Name 'regex' -value $RegularExpression -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/workflows' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnWorkflows += ( $response.Content | ConvertFrom-Json ).workflows
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnWorkflows

        if ( $returnWorkflows.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnWorkflows.count) workflows found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no workflows found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
