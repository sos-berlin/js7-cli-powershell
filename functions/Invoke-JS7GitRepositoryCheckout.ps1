function Invoke-JS7GitRepositoryCheckout
{
<#
.SYNOPSIS
Performs a checkout from a remote Git repository to a local repository

.DESCRIPTION
This cmdlet performs a checkout from a remote Git repository to the local repository.
This includes overwriting any objects in the local repository.

A local directory located in JETTY_BASE/resources/joc/repositories/rollout/TestCases
is mapped to a JOC Cockpit /TestCases inventory folder.

This cmdlet corresponds to using the following Git command:

* git checkout <branch> <tag>

The following REST Web Service API resources are used:

* /inventory/repository/git/checkout

.PARAMETER Folder
Specifies the JOC Cockpit inventory folder that maps to the Git repository.

.PARAMETER Local
Specifies that a repository holding scheduling objects that are local to the environment should be used.
This corresponds to the LOCAL category. If this switch is not used then the
ROLLOUT category is assumed for a repository that holds scheduling objects
intended for rollout to later environments such as test, prod.

.PARAMETER Branch
Specifies the name of the branch in the remote Git repository.

.PARAMETER Tag
Specifies the name of the tag in the remote Git repository.

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
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Invoke-JS7GitRepositoryCheckout -Folder /TestCases -Branch "v1.12"

Updates the local repository that maps to the JOC Cockpit /TestCases inventory folder from branch "v1.12" in the remote Git repository.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Local,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Branch,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Tag,
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

        if ( $Branch -and $Tag )
        {
            throw 'only one of the -Branch and -Tag arguments can be provided'
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }

    Process
    {
        if ( $Folder.endsWith('/') )
        {
            $Folder = $Folder.Substring( 0, $Folder.Length-1 )
        }

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body

        if ( $Local )
        {
            Add-Member -Membertype NoteProperty -Name 'category' -value 'LOCAL' -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'category' -value 'ROLLOUT' -InputObject $body
        }

        if ( $Branch )
        {
            Add-Member -Membertype NoteProperty -Name 'branch' -value $Branch -InputObject $body
        }

        if ( $Tag )
        {
            Add-Member -Membertype NoteProperty -Name 'tag' -value $Tag -InputObject $body
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
        $response = Invoke-JS7WebRequest -Path '/inventory/repository/git/checkout' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $requestResult
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): output to stdout: $($requestResult.stdout)"
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): output to stderr: $($requestResult.stdout)"
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): checkout performed for folder: $Folder"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
