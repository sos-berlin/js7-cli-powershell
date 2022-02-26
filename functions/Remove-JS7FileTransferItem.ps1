function Remove-JS7FileTransferItem
{
<#
.SYNOPSIS
Removes file transfer configurations from the JOC Cockpit inventory.

.DESCRIPTION
This cmdlet removes file transfer configurations from the JOC Cockpit inventory.

.PARAMETER Name
Specifies the name of the file transfer configuration.
The name is used to display the subtab holding the file transfer configuration in the JOC Cockpit GUI.

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
This cmdlet accepts pipelined objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7FileTransferItem -Name sample22

Removes the indicated file transfer configuration from the JOC Cockpit inventory.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name,
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

        $removableConfigurations = @()
    }

    Process
    {
        $removableConfigurations += $Name
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/xmleditor/read' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $fileTransferItems = ( $response.Content | ConvertFrom-Json ).configurations
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }


        foreach( $removableConfiguration in $removableConfigurations )
        {
            $removed = $False

            foreach( $fileTransferItem in $fileTransferItems )
            {
                if ( $fileTransferItem.name -eq $removableConfiguration )
                {
                    $body = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
                    Add-Member -Membertype NoteProperty -Name 'id' -value $fileTransferItem.id -InputObject $body
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body

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

                    if ( $PSCmdlet.ShouldProcess( $fileTransferItem.name, '/xmleditor/remove' ) )
                    {
                        [string] $requestBody = $body | ConvertTo-Json -Depth 100
                        $response = Invoke-JS7WebRequest -Path '/xmleditor/remove' -Body $requestBody

                        if ( $response.StatusCode -eq 200 )
                        {
                            $requestResult = ( $response.Content | ConvertFrom-Json )

                            if ( !$requestResult.removed )
                            {
                                throw ( $response | Format-List -Force | Out-String )
                            }
                        } else {
                            throw ( $response | Format-List -Force | Out-String )
                        }

                        Write-Verbose ".. $($MyInvocation.MyCommand.Name): file transfer configuration removed: $($fileTransferItem.name)"
                    }

                    $removed = $True
                    break;
                }
            }

            if ( !$removed )
            {
                throw "$($MyInvocation.MyCommand.Name): file transfer configuration not found: $removableConfiguration"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
