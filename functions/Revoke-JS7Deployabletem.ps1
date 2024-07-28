function Revoke-JS7DeployableItem
{
<#
.SYNOPSIS
Revokes deployable inventory items

.DESCRIPTION
This cmdlet revokes deployable inventory items.

Inventory items are preferably retrieved using the Get-JS7DeployableItem cmdlet. The output can be piped to this cmdlet.

The following REST Web Service API resources are used:

* /inventory/deployment/revoke

.PARAMETER Folder
Specifies the folder in which the inventory objects is located.

.PARAMETER ObjectName
Specifies the name of an inventory item that should be revoked.

.PARAMETER ObjectType
Specifies the type of object to be revoked.

The following object types are available

* WORKFLOW
* FILEORDERSOURCE
* JOBRESOURCE
* NOTICEBOARD
* LOCK

.PARAMETER DeployablesVersions
Specifies an array of object versions that include the commitId attribute required to revoke a specific version of an inventory item.

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

Get-JS7DeployableItem -Folder /ProductDemo -Recursive | Revoke-JS7Deployabletem -ControllerId 'controller'

Reads inventory items from the given folder recursively and revokes the objects from the specified Controller.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectName,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectType,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [object[]] $DeployablesVersions,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $ControllerId,
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

        $deployables = @()
    }

    Process
    {
        $deployable = New-Object PSObject
        $configuration = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value "$($Folder)/$($ObjectName)" -InputObject $configuration
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $ObjectType -InputObject $configuration
        Add-Member -Membertype NoteProperty -Name 'commitId' -value $DeployablesVersions[0].commitId -InputObject $configuration

        Add-Member -Membertype NoteProperty -Name 'configuration' -value $configuration -InputObject $deployable

        $deployables += $deployable
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployables -InputObject $body

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
        $response = Invoke-JS7WebRequest -Path '/inventory/deployment/revoke' -Body $requestBody

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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($deployables.count) objects revoked"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
