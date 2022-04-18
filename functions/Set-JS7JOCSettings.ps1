function Set-JS7JOCSettings
{
<#
.SYNOPSIS
Stores JS7 settings

.DESCRIPTION
A number of settings can be specified for example with the JOC Cockpit Settings page and with Identity Services.
This cmdlet allows to store settings programmatically.

Settings include a hierarchy of objects and are available with

$settings,$item = Get-JS7JOCSettings

* $settings: this object holds the original object returned by the REST Web Service API.
* $item: this object holds the PowerShell representation of the configuration items.

Changes should not be applied to $settings, but to $item like this:

$item.cleanup.deployment_history_versions.value = 5;

Settings are stored by pipelining the original $settings object and by using the -Item parameter with the modified $item object like this:

$settings | Set-JS7JOCSettings -Item $item

The following REST Web Service API resources are used:

* /configuration/save

.PARAMETER ConfigurationType
Populated from a pipelined settings object.

.PARAMETER ConfigurationItem
Populated from a pipelined settings object.

.PARAMETER ObjectType
Populated from a pipelined settings object.

.PARAMETER Name
Populated from a pipelined settings object.

.PARAMETER Id
Populated from a pipelined settings object.

.PARAMETER ControllerId
Populated from a pipelined settings object.

.PARAMETER Account
Populated from a pipelined settings object.

.PARAMETER Shared
Populated from a pipelined settings object.

.PARAMETER Item
Specifies the PowerShell object of a configuratiom item to be stored.

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
This cmdlet accepts two objects:

* settings: the settings object as returned from the Get-JS7JOCSettings cmdlet
* item: a PowerShell object holding the configuration items

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
$settings,$item = Get-JS7JOCSettings;
$item.cleanup.deployment_history_versions.value = 5;
$settings | Set-JS7JOCSettings -Item $item

Reads, modifies and stores global settings.

.EXAMPLE
$settings,$item = Get-JS7JOCSettings -ConfigurationType 'IAM' -ObjectType 'LDAP' -Name 'PublicLDAP';
$item.ldap.expert.iamLdapServerUrl = 'ldap://ldap.forumsys.com:389';
$settings | Set-JS7JOCSettings -Item $item

Reads, modifies and stores settings of an LDAP Identity Service.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('GLOBALS','IAM',IgnoreCase = $False)]
    [string] $ConfigurationType = 'GLOBALS',
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ConfigurationItem,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectType,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Id,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Account,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Shared,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $Item,
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
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'configurationType' -value $ConfigurationType -InputObject $body

        if ( $ObjectType )
        {
            Add-Member -Membertype NoteProperty -Name 'objectType' -value $ObjectType -InputObject $body
        }

        if ( $Name )
        {
            Add-Member -Membertype NoteProperty -Name 'name' -value $Name -InputObject $body
        }

        if ( $Item )
        {
            Add-Member -Membertype NoteProperty -Name 'configurationItem' -value ( $Item | ConvertTo-Json -Depth 100 ) -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'configurationItem' -value $ConfigurationItem -InputObject $body
        }

        if ( $Id )
        {
            Add-Member -Membertype NoteProperty -Name 'id' -value $Id -InputObject $body
        }

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        if ( $Account )
        {
            Add-Member -Membertype NoteProperty -Name 'account' -value $Account -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'account' -value $script:jsWebServiceCredential.UserName -InputObject $body
        }

        if ( $Shared )
        {
            Add-Member -Membertype NoteProperty -Name 'shared' -value $True -InputObject $body
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

        if ( $PSCmdlet.ShouldProcess( 'settings', '/configuration/save' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/configuration/save' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json )

                if ( !$requestResult )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): settings stored"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
