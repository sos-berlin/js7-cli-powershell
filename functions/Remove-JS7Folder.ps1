function Remove-JS7Folder
{
<#
.SYNOPSIS
Removes a folder from the JOC Cockpit inventory

.DESCRIPTION
This cmdlet marks for deletion a folder and its contents, i.e. deployable and releasable objects
in the JOC Cockpit inventory.

The objects from the folder are not immediately erased, instead this change has to be committed:

* For deployable objects use of the cmdlet the Publish-JS7DeployableItem cmdlet with the -Delete switch is required.
* For releasable objects use of the cmdlet the Publish-JS7ReleasableItem cmdlet with the -Delete switch is required.

The following REST Web Service API resources are used:

* /inventory/remove/folder

.PARAMETER Folder
Specifies the folder and optionally sub-folders to be removed.

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
This cmdlet does not accept pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7Folder -Folder /some/folder

Removes the specified folder from the JOC Cockpit inventory.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
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
        Add-Member -Membertype NoteProperty -Name 'path' -value $Folder -InputObject $body

        if ( $PSCmdlet.ShouldProcess( $Path, '/inventory/remove/folder' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/remove/folder' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): folder removed: $Path"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
