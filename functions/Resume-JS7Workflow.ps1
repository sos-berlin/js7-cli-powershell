function Resume-JS7Workflow
{
<#
.SYNOPSIS
Resumes a workflow in the JS7 Controller

.DESCRIPTION
This cmdlet resumes a workflow in a JS7 Controller.

Any orders in a resumed workflow will continue.

The following REST Web Service API resources are used:

* /workflows/resume

.PARAMETER WorkflowPath
Specifies the identifier of the workflow.

The path includes the folder, sub-folders and the name of the workflow.

.PARAMETER Folder
Specifies the folder and optionally sub-folders from which workflows should be resumed.

.PARAMETER Recursive
When used with the -Folder parameter specifies that any sub-folders should be looked up.
By default no sub-folders will be searched for workflows.

.PARAMETER All
Optionally specifies tha all workflows should be resumed.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller from which to resume workflows.

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
This cmdlet accepts pipelined workflow objects that are e.g. returned from the Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Resume-JS7Workflow -WorkflowPath /ProductDemo/WorkflowSuspension/pdwWorkflowSuspension

Resumes the workflow with the given path.

.EXAMPLE
Resume-JS7Worfklow -Folder /some_workflow_path -Recursive

Resumes suspended workflows that are available with the path /some_workflow_path and any sub-folders.

.EXAMPLE
Resume-JS7Workflow -All

Resumes all suspended workflows.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $All,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
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

        if ( $Folder -and $WorkflowPath )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -WorkflowPath or -Folder can be used"
        }

        $folders = @()
        $paths = @()
    }

    Process
    {
        if ( $Folder.endsWith('/') )
        {
            $Folder = $Folder.Substring( 0, $Folder.Length-1 )
        }

        if ( $Folder )
        {
            $folderObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $folderObj
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $folderObj
            $folders += $folderObj
        }

        if ( $WorkflowPath )
        {
            $paths += $WorkflowPath
        }
    }

    End
    {
        if ( $paths.count -or $folders.count -or $All )
        {
            $body = New-Object PSObject

            if ( $ControllerId )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            }

            if ( $folders )
            {
                Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
            }

            if ( $paths )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $paths -InputObject $body
            }

            if ( $All )
            {
                Add-Member -Membertype NoteProperty -Name 'all' -value $True -InputObject $body
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
            $response = Invoke-JS7WebRequest '/workflows/resume' $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): workflows resumed"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no workflows found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
