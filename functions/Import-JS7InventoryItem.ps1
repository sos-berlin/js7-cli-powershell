function Import-JS7InventoryItem
{
<#
.SYNOPSIS
Import inventory objects, e.g. workflows, schedules etc. from a JOC Cockpit archive file

.DESCRIPTION
JOC Cockpit inventory items can be exported with the Export-JS7InventoryItem cmdlet. The archive file 
created by the cmdlet can be imported by use of this cmdlet. This offers a mechanism to backup and to
restore inventory data, e.g. in case of switching the DBMS for JOC Cockpit or when upgrading to newer
JS7 releases.

.PARAMETER FilePath
Specifies the path to the archive file that includes objects for import to the JOC Cockpit inventory.

.PARAMETER ArchiveFormat
Specifies the type of the archive file that will be imported: ZIP, TAR.GZ.

.PARAMETER Folder
Optionally specifies the folder in the JOC Cockpit inventory to which imported objects paths should be added. 

Without this parameter any folders as specified with the import file will be used. 
New folders are automatically created and optionally existing folders will be overwritten.

.PARAMETER Overwrite
Specifies that existing objects in the JOC Cockpit inventory will be overwritten
from objects with the same path in the archive file.

Without this parameter objects from the import file are ignored if objects with the same path
exist in the JOC Cockpit inventory.

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
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Import-JS7InventoryItem -FilePath /tmp/export.zip

Imports any objects included with the import file ("export.zip"). Objects existing with the same path in 
the JOC Cockpit inventory will not be overwritten.

.EXAMPLE
Import-JS7InventoryItem -Folder /some_folder -FilePath /tmp/export.tar.gz -ArchiveFormat TAR.GZ -Overwrite

Imports any objects from the given import file. As a compressed tar file is used the respective archive format
is specified. Objects are added to the path /some_folder such as e.g. an object /myPath/myWorkflow that will be added to
the path /some_folder/myPath/myWorkflow.

Any objects existing with the same path in the JOC Cockpit inventory will be overwritten.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $FilePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ZIP','TAR.GZ')]
    [string] $ArchiveFormat = 'ZIP',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Overwrite,
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
        $stopWatch = Start-StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }
    
    Process
    {
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'file' -value $FilePath -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'archiveFormat' -value $ArchiveFormat -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'overwrite' -value ($Overwrite -eq $True) -InputObject $body

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

        $headers = @{ 'Encoding' = 'gzip, deflate'; 'Content-Type' = 'application/octet-stream' }       

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/import' -Body $requestBody -Headers $headers
        
        if ( $response.StatusCode -ne 200 )
        {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): file imported: $FilePath"                

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
