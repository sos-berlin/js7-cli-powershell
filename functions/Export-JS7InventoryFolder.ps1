function Export-JS7InventoryFolder
{
<#
.SYNOPSIS
Exports inventory items, e.g. workflows, schedules etc. from folders in JOC Cockpit

.DESCRIPTION
This cmdlet exports inventory items based on folders stored with JOC Cockpit.

An export is performed either to backup deployable and releasable objects that later on can be imported,
or to export objects for signing and later deployment with a JOC Cockpit operated in security level HIGH.

The process to export objects for signigng includes the following steps:

* export deployable objects to a compressed archive (.zip, .tar.gz),
* unzip the archive to the local file system,
* manually sign objects,
* zip signed objects and signature files to a compressed archive,
* import the archive and deploy the signed objects.

The following REST Web Service API resources are used:

* /inventory/export/folder

.PARAMETER Type
Optionally restricts the object type to export which is one of:

* Deployable Object Types
** WORKFLOW
** FILEORDERSOURCE
** JOBRESOURCE
** NOTICEBOARD
** LOCK
* Releasable Object Types
** INCLUDESCRIPT
** JOBTEMPLATE
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE
** REPORT

The -Type parameter can be used to restrict either deployable or releasable object types to be exported.
Without specifying this parameter objects of any type within the areas of releasable and deployable objects are exported
depending on use of the -Releasable and -Deployable parameters.

.PARAMETER Folder
Optionally specifies the folder for which all included inventory items should be exported.
This parameter is used alternatively to the -Path parameter that specifies export of an individual inventory item.

.PARAMETER Recursive
Specifies that all sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be searched for exportable objects.

.PARAMETER NoDraft
Specifies that no draft versions of releasable or deployable objects will be exported but only released/deployed versions.
Without this parameter the draft version of the inventory item will be exported if available.

If this switch is in place then depending on the presence of the -Latest parameter for deployable objects only the latest
deployed version will be used for export.

.PARAMETER NoReleased
Specifies that no released versions of the releasable objects will be exported but only draft versions if available.
Without this parameter any draft versions and released versions of inventory objects will be exported.

.PARAMETER NoDeployed
Specifies that no deployed versions of deployable objects will be exported but only draft versions.
Without this parameter the draft version of the inventory object will be exported if available.

.PARAMETER Valid
Specifies that only valid versions of inventory draft objects are eligible for export.
This applies to releasable and to deployable objects.
Without this parameter draft versions will be exported that are in progress and therefore are not valid.

.PARAMETER ForSigning
Specifies that deployable objects are exported for external signing and later import into a JOC Cockpit
instance operated for security level HIGH.

* The export file cannot include releasable objects as such objects are not subject to signing.
* The export file must be created from the same JOC Cockpit instance to which it will be imported for deployment.
* The process of export/signing/import must not exceed the max. idle time that is configured for a user's JOC Cockpit session.

Without this parameter the export file is created for backup purposes and can include any deployable and releasable objects.

.PARAMETER UseShortPath
Specifies that the export file will not use the absolute path of folders but will start from the last sub-folder specified with the -Folder argument.

.PARAMETER ControllerId
Specifies the ID of the Controller to which objects should be deployed after external signing.
This parameter is required if the -ForSigning parameter is used.

.PARAMETER FilePath
Specifies the path to the archive file that the exported inventory objects are written to.

.PARAMETER Format
Specifies the type of the archive file that will be returned: ZIP, TAR_GZ.

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
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns an octet-stream that is provided from an output file

.EXAMPLE
Export-JS7InventoryFolder -Folder /some_folder -FilePath /tmp/export.tar.gz -Format TAR_GZ

Exports any objects from the given folder to a compressed tar file.
This includes deployable and releasable inventory objects.
By default draft versions and deployed or released versions are used.

.EXAMPLE
Export-JS7InventoryFolder -Folder /some_folder -Recursive -NoReleased -FilePath /tmp/export.zip -ForSigning

Exports deployable objects recursively from the given folder to a zipped file that is used for signing.
After signing and adding the signature files to the export archive then this archive can be imported
and deployed in a JOC Cockpit instance operated for security level "high".

.EXAMPLE
Export-JS7InventoryFolder -Folder /some_folder -Type WORKFLOW -FilePath /tmp/export.zip

Exports workflows from the specified folder to a zipped file.

.EXAMPLE
Export-JS7InventoryFolder -Folder /ProductDemo/ErrorHandling -NoReleased -FilePath /tmp/export.zip

Exports any deployable inventory items such as workflows, resource locks etc. that are available
from the specified folder to a zipped file. The latest deployed version of the objects is used.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','JOBTEMPLATE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','REPORT',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReleased,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDeployed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForSigning,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $UseShortPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $FilePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ZIP','TAR_GZ',IgnoreCase = $False)]
    [string] $Format = 'ZIP',
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

        if ( $ForSigning -and !$ControllerId )
        {
            throw "$($MyInvocation.MyCommand.Name): if parameter -ForSigning is used then the -ControllerId parameter has to be specified."
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $formats = @{ 'ZIP' = 'zip'; 'TAR_GZ' = 'tar.gz' }
        $objectTypes = @('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','JOBTEMPLATE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')

        if (IsJOCVersion -Major 2 -Minor 7 -Patch 1 )
        {
            $objectTypes += 'REPORT'
        }

        $folders = @()
    }

    Process
    {
        $folders += $Folder
    }

    End
    {
        $body = New-Object PSObject

        $exportFile = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'format' -value $Format -InputObject $exportFile

        if ( $FilePath )
        {
            Add-Member -Membertype NoteProperty -Name 'filename' -value "$([System.IO.Path]::GetFileName($FilePath))" -InputObject $exportFile
        } else {
            Add-Member -Membertype NoteProperty -Name 'filename' -value "joc-export.$($formats.Item($Format))" -InputObject $exportFile
        }

        Add-Member -Membertype NoteProperty -Name 'exportFile' -value $exportFile -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'useShortPath' -value ($UseShortPath -eq $True) -InputObject $body

        $exportObject = New-Object PSObject

            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $exportObject

            if ( !$Type )
            {
                Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $objectTypes -InputObject $exportObject
            } else {
                Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $exportObject
            }

            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $exportObject
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $exportObject
            Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $exportObject
            Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $exportObject
            Add-Member -Membertype NoteProperty -Name 'withoutReleased' -value ($NoReleased -eq $True) -InputObject $exportObject

        if ( $ForSigning )
        {
            Add-Member -Membertype NoteProperty -Name 'forSigning' -value $exportObject -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $exportObject
            Add-Member -Membertype NoteProperty -Name 'shallowCopy' -value $exportObject -InputObject $body
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

        if ( $FilePath -and (Test-Path -Path $FilePath -PathType Leaf) )
        {
             Remove-Item -Path $FilePath -Force
        }

        # not used with Invoke-WebRequest -OutFile
        # $headers = @{'Accept' = 'application/json, text/plain, */*'; 'Accept-Encoding' = 'gzip, deflate'; 'Content-Disposition' = "attachment; filename*=UTF-8''joc-export.zip" }
        $headers = @{'Accept' = 'application/json, text/plain, */*'; 'Accept-Encoding' = 'gzip, deflate'}

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/export/folder' -Body $requestBody -Headers $headers -OutFile $FilePath

        if ( Test-Path -Path $FilePath -PathType Leaf )
        {
            if ( isPowerShellVersion 6 )
            {
                $bytes = Get-Content $FilePath -AsByteStream -TotalCount 1
            } else {
                $bytes = Get-Content $FilePath -Encoding byte -TotalCount 1
            }

            # if first character is { (7B, 123) then this indicates a JSON response holding an error
            if ( $bytes -eq '123' )
            {
                throw "$($MyInvocation.MyCommand.Name): error occurred: $(Get-Content $FilePath -Encoding UTF8 -TotalCount 200)"
            }
        } else {
            throw "$($MyInvocation.MyCommand.Name): error occurred:`n$($response | Format-List -Force | Out-String)"
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($exportObjects.count) items exported"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
