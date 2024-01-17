function Set-JS7NotificationConfiguration
{
<#
.SYNOPSIS
Stores the configuration of JOC Cockpit notifications

.DESCRIPTION
Any inventory objects can be stored to JOC Cockpit. The objects are passed on as PowerShell
objects and are converted by the cmdlet to their native JSON reperesentation.

The following REST Web Service API resources are used:

* /inventory/store

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, e.g. a workflow path that should be
stored to the inventory.

.PARAMETER Type
Specifies the object type which is one of:

** FOLDER
* Deployable object types
** WORKFLOW
** FILEORDERSOURCE
** JOBRESOURCE
** NOTICEBOARD
** LOCK
* Releasable object types
** INCLUDESCRIPT
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE

.PARAMETER Object
Specifies the object that should be stored to the inventory. This parameter expects a PowerShell
custom object [PSCustomObject] as e.g. returned by the Get-JS7InventoryItem cmdlet.

The custom object is converted to JSON by this cmdlet.

.PARAMETER Valid
Specifies that the inventory object has been validate before using this cmdlet

If such orders exist with a Controller and the -Submit parameter is used then they are cancelled and re-created.

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

.OUTPUTS
This cmdlet does not return any output.

.EXAMPLE
[xml] $xmlConf=(Get-JS7NotificationConfiguration).configuration
[PSCustomObject] $jsonConf=((Get-JS7NotificationConfiguration).configurationJson | ConvertFrom-Json -Depth 100)
Set-JS7NotificationConfiguration -XmlConfiguration $xmlConf -JsonConfiguration $jsonConf

Reads and stores the inventory object of a file order source.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [xml] $XmlConfiguration,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $JsonConfiguration,
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

        if ( ! $XmlConfiguration -and ! $JsonConfiguration )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -XmlConfiguration or -JsonConfiguration has to be specified"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name):"
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'configuration' -value $XmlConfiguration.OuterXml -InputObject $body

        if ( $JsonConfiguration )
        {
            Add-Member -Membertype NoteProperty -Name 'configurationJson' -value ( $JsonConfiguration | ConvertTo-Json -Depth 100 ) -InputObject $body
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

        if ( $PSCmdlet.ShouldProcess( 'notification configuration', '/notification/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/notification/store' -Body $requestBody

            if ( !$response.StatusCode -eq 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
