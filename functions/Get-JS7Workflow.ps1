function Get-JS7Workflow
{
<#
.SYNOPSIS
Returns workflows from the JS7 JOC Cockpit.

.DESCRIPTION
Workflows are returned from JOC Cockpit - independent of their deployment status with specific Controller instances..
Workflows can be selected either by the folder of the workflow location including sub-folders or by an individual workflow.

Resulting workflows can be forwarded to other cmdlets for pipelined bulk operations.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow that should be returned.
If the name of a workflow is specified then the -Directory parameter is used to determine the folder.
Otherwise the -WorkflowPath parameter is assumed to include the full path and name of the workflow.

One of the parameters -Directory or -WorkflowPath has to be specified.

.PARAMETER Directory
Optionally specifies the folder for which workflows should be returned. 

One of the parameters -Directory and -WorkflowPath has to be specified.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up. By default no sub-folders will be searched for workflows.

.PARAMETER RegularExpression
Limits result to workflow paths that correspond the given regular expression.

.PARAMETER Compact
Specifies that fewer attributes of a workflow are returned.

.OUTPUTS
This cmdlet returns an array of workflow objects.

.EXAMPLE
$workflows = Get-JS7Workflow

Returns all workflows.

.EXAMPLE
$workflows = Get-JS7Workflow -Directory /some_path -Recursive

Returns all workflows that are configured with the specified path
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
    [string] $Directory = '/',
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

        $returnWorkflows = @()        
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Directory=$Directory, Workflow=$Workflow"

        if ( !$Directory -and !$WorkflowPath )
        {
            throw "$($MyInvocation.MyCommand.Name): no directory and no workflow specified, use -Directory or -WorkflowPath"
        }

        if ( $Directory -and $Directory -ne '/' )
        { 
            if ( $Directory.Substring( 0, 1) -ne '/' ) {
                $Directory = '/' + $Directory
            }
        
            if ( $Directory.Length -gt 1 -and $Directory.LastIndexOf( '/' )+1 -eq $Directory.Length )
            {
                $Directory = $Directory.Substring( 0, $Directory.Length-1 )
            }
        }

        if ( $Directory -eq '/' -and !$WorkflowPath -and !$Recursive )
        {
            $Recursive = $true
        }
        
        if ( $WorkflowPath ) 
        {
            if ( (Get-JS7Object-Basename $WorkflowPath) -ne $WorkflowPath ) # workflow name includes a path
            {
                $Directory = Get-JS7Object-Parent $WorkflowPath
            } else { # workflow name includes no directory
                if ( $Directory -eq '/' )
                {
                    $WorkflowPath = $Directory + $WorkflowPath
                } else {
                    $WorkflowPath = $Directory + '/' + $WorkflowPath
                }
            }
        }


        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        
        if ( $Compact )
        {
            Add-Member -Membertype NoteProperty -Name 'compact' -value $true -InputObject $body
        }

        if ( $WorkflowPath )
        {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $objWorkflow

            Add-Member -Membertype NoteProperty -Name 'workflowIds' -value @( $objWorkflow ) -InputObject $body
        }

        if ( $Directory )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Directory -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $true) -InputObject $objFolder

            Add-Member -Membertype NoteProperty -Name 'folders' -value @( $objFolder ) -InputObject $body
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
    }
    
    End
    {
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
