function Invoke-JS7GitRepositoryAdd
{
<#
.SYNOPSIS
Adds all unstaged changes to the local Git repository staging area

.DESCRIPTION
This cmdlet adds changes from directories and sub-directories of the local repository
to the repository staging area. This cmdlet typically is used after having stored changes
from JOC Cockpit inventory folders to the local repository by use of the Set-JS7RepositoryItem cmdlet.

A local directory located in JETTY_BASE/resources/joc/repositories/rollout/TestCases
maps to a JOC Cockpit /TestCases inventory folder.

This cmdlet corresponds to using the following Git command:

* git add .

The following REST Web Service API resources are used:

* /inventory/repository/git/add

.PARAMETER Folder
Specifies the JOC Cockpit inventory folder that maps to the Git repository.

.PARAMETER Local
Specifies that a repository holding scheduling objects that are local to the environment should be used.
This corresponds to the LOCAL category. If this switch is not used then the
ROLLOUT category is assumed for a repository that holds scheduling objects
intended for rollout to later environments such as test, prod.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Invoke-JS7GitRepositoryAdd -Folder /TestCases

Adds changes from the local repository that maps to the JOC Cockpit /TestCases inventory folder to the repository staging area.

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
        $response = Invoke-JS7WebRequest -Path '/inventory/repository/git/add' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): output to stdout: $($requestResult.stdout)"
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): output to stderr: $($requestResult.stdout)"
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): objects added from folder: $Folder"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
