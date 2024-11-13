function Set-JS7FileTransferItem
{
<#
.SYNOPSIS
Stores a file transfer configuration to the JOC Cockpit inventory

.DESCRIPTION
File transfer configuration objects can be stored to JOC Cockpit. The configuration is passed on from an XML
object and is converted by the cmdlet to its native JSON reperesentation.

The following REST Web Service API resources are used:

* /xmleditor/schema/assign
* /xmleditor/apply
* /xmleditor/store
* /xmleditor/validate

.PARAMETER Name
Specifies the name of the file transfer configuration.
The name is used to display the subtab holding the file transfer configuration in the JOC Cockpit GUI.

.PARAMETER Configuration
Specifies the XML object that should be stored to the inventory. This parameter expects an XML
object [XML] as e.g. returned by the Get-JS7FileTransferItem cmdlet.

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
$xml = Get-JS7FileTransferItem -Name 'primaryAgent'
Set-JS7FileTransferItem -Name 'newConfig' -Configuration $xml

Stores the file transfer configuration object to a new entry.

.EXAMPLE
[xml] $xml = '<?xml version="1.0" encoding="UTF-8" standalone="no" ?><Configurations/>'
Set-JS7FileTransferItem -Name 'newConfig' -Configuration $xml

Stores the given XML file transfer configuration to the JOC Cockpit inventory.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [xml] $Configuration,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Schema = 'YADE_configuration_v1.12.xsd',
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
        $Configuration.PreserveWhiteSpace = $True

        Write-Debug ".. $($MyInvocation.MyCommand.Name): Name = $Name"
    }

    End
    {
        # Create configuration in inventory if it does not exist

        if ( ! (Get-JS7FileTransferItem -Name $Name) )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'uri' -value $Schema -InputObject $body

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

            if ( $PSCmdlet.ShouldProcess( 'file transfer schema assign', '/xmleditor/schema/assign' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/xmleditor/schema/assign' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $schemaObject = ( $response.Content | ConvertFrom-Json )
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }

            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'configuration' -value '<?xml version="1.0" encoding="UTF-8" standalone="no" ?><Configurations/>' -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'configurationJson' -value '{}' -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'id' -value 0 -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'name' -value $Name -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'schema' -value $Schema -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'schemaIdentifier' -value $schemaObject.schemaIdentifier -InputObject $body

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

            if ( $PSCmdlet.ShouldProcess( 'file transfer store', '/xmleditor/store' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/xmleditor/store' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $configurationId = ( $response.Content | ConvertFrom-Json ).id
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }
        }


        # Validate configuration

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'configuration' -value $Configuration.OuterXml -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'schemaIdentifier' -value $schemaObject.schemaIdentifier -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'file transfer validate', '/xmleditor/validate' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/xmleditor/validate' -Body $requestBody

            if ( !$response.StatusCode -eq 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        }


        # Apply configuration

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'configuration' -value $Configuration.OuterXml -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'id' -value $configurationId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'name' -value $Name -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'schemaIdentifier' -value $schemaObject.schemaIdentifier -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'file transfer apply', '/xmleditor/apply' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/xmleditor/apply' -Body $requestBody

            if ( !$response.StatusCode -eq 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
