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

Consider that this cmdlet requires PowerShell version 6.0 or newer.

.PARAMETER FilePath
Specifies the path to the archive file that includes objects for import to the JOC Cockpit inventory.

.PARAMETER Format
Specifies the type of the archive file that will be imported: ZIP, TAR.GZ.

.PARAMETER TargetFolder
Optionally specifies the folder in the JOC Cockpit inventory to which imported objects paths should be added.

Without this parameter any folders as specified with the import file will be used.
New folders are automatically created and optionally existing folders will be overwritten.

.PARAMETER Prefix
Specifies a prefix - followed by a dash - to be prepended to object names in case that a target object
with the same name exists and that the -Overwrite switch has not been used.

If an object with the same name including the prefix exists then a unique name is created from an
incremental number that is inserted between the prefix and the dash.

.PARAMETER Suffix
Specifies a suffix - preceded by a dash - to be appended to object names in case that a target object
with the same name exists and that the -Overwrite switch has not been used.

If an object with the same name including the suffix exists then a unique name is created from an
incremental number that is inserted between the suffix and the dash.

If both -Prefix and -Suffix parameters are specified then the -Prefix parameter is ignored.

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

Imports any objects included with the import file "export.zip". Objects existing with the same path in
the JOC Cockpit inventory will not be overwritten.

.EXAMPLE
Import-JS7InventoryItem -TargetFolder /import -FilePath /tmp/export.tar.gz -Format TAR.GZ -Overwrite

Imports any objects from the given import file. As a compressed tar file is used the respective archive format
is specified. Objects are added to the path /some_folder such as e.g. an object /myPath/myWorkflow will be added to
the path /some_folder/myPath/myWorkflow.

Any objects existing with the same path in the JOC Cockpit inventory will be overwritten.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $FilePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ZIP','TAR.GZ')]
    [string] $Format = 'ZIP',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $TargetFolder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Prefix,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Suffix,
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
        $stopWatch = Start-JS7StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        if ( $Overwrite -and ($Suffix -or $Prefix) )
        {
            throw "$($MyInvocation.MyCommand.Name): Conflicting parameters -Overwrite and -Suffix, -Prefix"
        }

        if ( !(isPowerShellVersion 6) )
        {
            throw "$($MyInvocation.MyCommand.Name): Cmdlet not supported for PowerShell versions older that 6.0"
        }
    }

    Process
    {
        try
        {
            # see https://get-powershellblog.blogspot.com/2017/09/multipartform-data-support-for-invoke.html
            # requires PowerShell > 0, version before 6.0 do not support MultipartFormDataContent in a POST bodys
            $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

            $multipartFile = $FilePath
            $fileStream = [System.IO.FileStream]::new($multipartFile, [System.IO.FileMode]::Open)
            $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $fileHeader.Name = 'file'
            $fileHeader.FileName = [System.IO.Path]::GetFileName( $FilePath )
            $fileContent = [System.Net.Http.StreamContent]::new( $fileStream )
            $fileContent.Headers.ContentDisposition = $fileHeader
            $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/octet-stream")
            $multipartContent.Add( $fileContent )

            $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $stringHeader.Name = "format"
            $stringContent = [System.Net.Http.StringContent]::new( $Format )
            $stringContent.Headers.ContentDisposition = $stringHeader
            $multipartContent.Add( $stringContent )

            $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $stringHeader.Name = "targetFolder"
            $stringContent = [System.Net.Http.StringContent]::new( $TargetFolder )
            $stringContent.Headers.ContentDisposition = $stringHeader
            $multipartContent.Add( $stringContent )

            $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $stringHeader.Name = "overwrite"
            $StringContent = [System.Net.Http.StringContent]::new( ($Overwrite -eq $True) )
            $stringContent.Headers.ContentDisposition = $stringHeader
            $multipartContent.Add( $stringContent )

            $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $stringHeader.Name = "prefix"
            $stringContent = [System.Net.Http.StringContent]::new( $Prefix )
            $stringContent.Headers.ContentDisposition = $stringHeader
            $multipartContent.Add( $stringContent )

            $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $stringHeader.Name = "suffix"
            $stringContent = [System.Net.Http.StringContent]::new( $Suffix )
            $stringContent.Headers.ContentDisposition = $stringHeader
            $multipartContent.Add( $stringContent )

            if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
            {
                $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
                $stringHeader.Name = "comment"
                $stringContent = [System.Net.Http.StringContent]::new( $AuditComment )
                $stringContent.Headers.ContentDisposition = $stringHeader
                $multipartContent.Add( $stringContent )

                $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
                $stringHeader.Name = "timeSpent"
                $stringContent = [System.Net.Http.StringContent]::new( $AuditComment )
                $stringContent.Headers.ContentDisposition = $stringHeader
                $multipartContent.Add( $stringContent )

                $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
                $stringHeader.Name = "ticketLink"
                $stringContent = [System.Net.Http.StringContent]::new( $AuditComment )
                $stringContent.Headers.ContentDisposition = $stringHeader
                $multipartContent.Add( $stringContent )
            }

            $response = Invoke-JS7WebRequest -Path '/inventory/import' -Body $multipartContent -Method 'POST' -ContentType $Null

            if ( $response.StatusCode -ne 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): file imported: $FilePath"
        } catch {
            $message = $_.Exception | Format-List -Force | Out-String
            throw $message
        } finally {
            if ( $fileStream )
            {
                $fileStream.Close()
                $fileStream.Dispose()
            }
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
