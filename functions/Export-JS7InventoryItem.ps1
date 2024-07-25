function Export-JS7InventoryItem
{
<#
.SYNOPSIS
Exports inventory items, e.g. workflows, schedules etc. from JOC Cockpit

.DESCRIPTION
This cmdlet exports inventory items that are stored with JOC Cockpit.

* Deployable Objects: use of the -Deployable parameter
** Inventory items such as workflows are deployed to a JS7 Controller. The -Type parameter can be used to restrict object types.
** When exporting deployable objects then either a draft version can be used or the latest deployed version by use of the -Deployed parameter.
* Releasable Objects: use of the -Releasable parameter
** Inventory items such as calendars and schedules are not deployed to a Controller but are used by JOC Cockpit.
** When exporting releasable objects then either a draft version can be used or the latest released version by use of the -Released parameter.

An export is performed either to backup deployable and releasable objects that later on can be imported,
or to export objects for signing and later deployment with a JOC Cockpit operated in security level HIGH.

The process to export objects for signigng includes the following steps:

* export deployable objects to a compressed archive (.zip, .tar.gz),
* unzip the archive to the local file system,
* manually sign objects,
* zip signed objects and signature files to a compressed archive,
* import the archive and deploy the signed objects.

The following REST Web Service API resources are used:

* /inventory/deployable
* /inventory/deployables
* /inventory/releasable
* /inventory/releasables
* /inventory/export

.PARAMETER Path
Specifies the path and name of an individual inventory item that should be exported, e.g. a workflow.

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

.PARAMETER Releasable
Specifies that only releasable objects should be exported that include the object types:

* INCLUDESCRIPT
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* SCHEDULE
* REPORT

If none of the parameters -Releasable or -Deployable is used then both releasable and deployable inventory items are exported.

.PARAMETER Deployable
Specifies that only deployable objects should be exported that include the object types:

** WORKFLOW
** FILEORDERSOURCE
** JOBRESOURCE
** NOTICEBOARD
** LOCK

If none of the parameters -Releasable or -Deployable is used then both releasable and deployable inventory items are exported.

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

.PARAMETER Latest
Specifies that for deployable objects the latest deployed version is eligible for export.

.PARAMETER Valid
Specifies that only valid versions of inventory draft objects are eligible for export.
This applies to releasable and to deployable objects.
Without this parameter draft versions will be exported that are in progress and therefore are not valid.

.PARAMETER NoRemoved
Optionally specifies that no removed objects should be added to the export file. Such objects are marked for deletion, however,
deletion has not yet been confirmed by a deploy/release operation that permanently erases objects.

.PARAMETER ForSigning
Specifies that deployable objects are exported for external signing and later import into a JOC Cockpit
instance operated for security level HIGH.

* The export file cannot include releasable objects as such objects are not subject to signing.
* The export file must be created from the same JOC Cockpit instance to which it will be imported for deployment.
* The process of export/signing/import must not exceed the max. idle time that is configured for a user's JOC Cockpit session.

Without this parameter the export file is created for backup purposes and can include any deployable and releasable objects.

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
This cmdlet returns an octet-stream that can be piped to an output file, e.g. with the Out-File cmdlet.

.EXAMPLE
Export-JS7InventoryItem -Folder /some_folder -FilePath /tmp/export.tar.gz -Format TAR_GZ

Exports any objects from the given folder to a compressed tar file.
This includes deployable and releasable inventory objects.
By default draft versions and deployed or released versions are used.

.EXAMPLE
Export-JS7InventoryItem -Folder /some_folder -Deployable -FilePath /tmp/export.zip -ForSigning

Exports deployable objects only from the given folder to a zipped file that is used for signing.
After signing and adding the signature files to the export archive then this archive can be imported
and deployed in a JOC Cockpit instance operated for security level "high".

.EXAMPLE
Export-JS7InventoryItem -Path /some_folder/some_workflow -Type WORKFLOW -FilePath /tmp/export.zip

Exports the specified workflow from the indcated path to a zipped file.
Use of the -Path parameter requires to specify the -Type parameter for the object type.

Depending on availability the draft version or the latest deployed version of the workflow is used.
If a draft version is available then it is eligible for export independent from the fact that the draft is valid or invalid.

.EXAMPLE
Export-JS7InventoryItem -Path /some_folder/some_workflow -Type WORKFLOW -Valid -FilePath /tmp/export.zip

Exports the specified workflow from the indcated path to a zipped file.
Use of the -Path parameter requires to specify the -Type parameter for the object type.

Depending on availability the draft version or the latest deployed version of the workflow is used.
A draft version is considered only if it is valid otherwise the deployed version is used.

.EXAMPLE
Export-JS7InventoryItem -Folder /some_folder -Deployable -FilePath /tmp/export.zip

Exports any deployable inventory items such as workflows, resource locks etc. that are available
from the specified folder to a zipped file. The latest deployed version of the objects is used.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','JOBTEMPLATE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','REPORT',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Releasable,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Deployable,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReleased,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDeployed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Latest,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoRemoved,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForSigning,
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
        $deployableTypes = @('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK')
        $releasableTypes = @('INCLUDESCRIPT','JOBTEMPLATE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')

        if (IsJOCVersion -Major 2 -Minor 7 -Patch 1 )
        {
            $releasableTypes += 'REPORT'
        }

        $exportObjects = @{}
        $deployablesObj = $null
        $releasablesObj = $null
    }

    Process
    {
        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }

        if ( $Path -and !$Type )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify the object type, use -Type parameter"
        }

        if ( $Path -and ($Type.count -gt 1) )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify a single object type, use -Type parameter"
        }

        if ( $Path -and $Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( !$Path -and !$Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -Path or -Folder has to be used"
        }

        if ( !$Deployable -and !$Releasable )
        {
            $Deployable = $True
            $Releasable = $True
        }

        if ( $ForSigning )
        {
            $NoRemoved = $True
        }

        if ( $Releasable )
        {
            if ( $Path -and ($releasableTypes -contains $Type[0]) )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutReleased' -value ($NoReleased -eq $True) -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/releasable' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $releasableObject = ( $response.Content | ConvertFrom-Json ).releasable

                    if ( !$releasableObject.id )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                if ( $releasableObject.folder -and !$releasableObject.folder.endsWith( '/' ) )
                {
                    $releasableObject.folder += '/'
                }

                $exportKey = "$($releasableObject.folder)-$($releasableObject.objectName)-$($releasableObject.objectType)"

                if ( !$exportObjects.Item( $exportKey ) )
                {
                    $exportObjects.Add( $exportKey, @{ 'area' = 'releasable'; 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; 'released' = $releasableObject.released } )
                }
            } elseif ( $Folder ) {
                $body = New-Object PSObject

                if ( !$Type )
                {
                    Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $releasableTypes -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
                }

                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutReleased' -value ($NoReleased -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutRemovedObjects' -value ($WithoutRemoved -eq $True) -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/releasables' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $releasableItems = ( $response.Content | ConvertFrom-Json )
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                $releasableObjects = $releasableItems.releasables

                if ( $releasableItems.folders )
                {
                    $releasableObjects += $releasableItems.folders.releasables
                }

                foreach( $releasableObject in $releasableObjects )
                {
                    if ( $releasableObject.id )
                    {
                        if ( $releasableObject.folder -and !$releasableObject.folder.endsWith( '/' ) )
                        {
                            $releasableObject.folder += '/'
                        }

                        $exportKey = "$($releasableObject.folder)-$($releasableObject.objectName)-$($releasableObject.objectType)"
                        if ( !$exportObjects.Item( $exportKey ) )
                        {
                            $exportObject = @{ 'area' = 'releasable'; 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; ; 'released' = $releasableObject.released }

                            if ( $object.type -eq 'FOLDER' )
                            {
                                $exportObject.Add( 'recursive', ($Recursive -eq $True) )
                            }

                            $exportObjects.Add( $exportKey, $exportObject )
                        }
                    }
                }
            }
        }

        if ( $Deployable )
        {
            if ( $Path -and ($deployableTypes -contains $Type[0]) )
            {
                $body = New-Object PSObject

                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'latest' -value ($Latest -eq $True) -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/deployable' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $deployableObject = ( $response.Content | ConvertFrom-Json ).deployable

                    if ( !$deployableObject.id )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                $exportKey = "$($deployableObject.folder)-$($deployableObject.objectName)-$($deployableObject.objectType)"

                if ( !$exportObjects.Item( $exportKey ) )
                {
                    if ( $NoDraft )
                    {
                        if ( !$deployableObject.deployablesVersions.count -or ( $deployableObject.deploymentId -ne $deployableObject.deployablesVersions[0].deploymentId ) )
                        {
                            throw "$($MyInvocation.MyCommand.Name): could not find deployment for object: $Path"
                        }
                    }

                    if ( $deployableObject.deployablesVersions -and $deployableObject.deployablesVersions[0].commitId )
                    {
                        $commitId = $deployableObject.deployablesVersions[0].commitId
                    } else {
                        $commitId = $null
                    }

                    if ( $commitId )
                    {
                        $exportObjects.Add( $exportKey, @{ 'area' = 'deployable'; 'path' = $Path; 'type' = $Type[0]; 'deployed' = $deployableObject.deployed; 'commitId' = $commitId } )
                    } else {
                        $exportObjects.Add( $exportKey, @{ 'area' = 'deployable'; 'path' = $Path; 'type' = $Type[0]; 'deployed' = $deployableObject.deployed } )
                    }
                }
            } elseif ( !$Path ) {
                $body = New-Object PSObject

                if ( $Folder )
                {
                    Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $deployableTypes -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
                }

                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutRemovedObjects' -value ($NoRemoved -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'latest' -value ($Latest -eq $True) -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/deployables' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $deployableItems = ( $response.Content | ConvertFrom-JSON )
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                $deployableObjects = $deployableItems.deployables

                if ( $deployableItems.folders )
                {
                    $deployableObjects += $deployableItems.folders.deployables
                }

                foreach( $deployableObject in $deployableObjects )
                {
                    if ( $deployableObject.folder -and !$deployableObject.folder.endsWith( '/' ) )
                    {
                        $deployableObject.folder += '/'
                    }

                    $exportKey = "$($deployableObject.folder)-$($deployableObject.objectName)-$($deployableObject.objectType)"
                    if ( !$exportObjects.Item( $exportKey ) )
                    {
                        if ( $deployableObject.deployablesVersions -and $deployableObject.deployablesVersions[0].commitId )
                        {
                            $commitId = $deployableObject.deployablesVersions[0].commitId
                        } else {
                            $commitId = $null
                        }

                        $exportObject = @{ 'area' = 'deployable'; 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'deployed' = $deployableObject.deployed }

                        if ( $commitId )
                        {
                            $exportObject.Add( 'commitId', $deployableObject.deployablesVersions[0].commitId )
                        }

                        if ( $object.type -eq 'FOLDER' )
                        {
                            $exportObject.Add( 'recursive', ($Recursive -eq $True) )
                        }

                        $exportObjects.Add( $exportKey, $exportObject )
                    }
                }
            }
        }
    }

    End
    {
        if ( $exportObjects )
        {
            $body = New-Object PSObject

            $exportFile = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'format' -value "$Format" -InputObject $exportFile

            if ( $FilePath )
            {
                Add-Member -Membertype NoteProperty -Name 'filename' -value "$([System.IO.Path]::GetFileName($FilePath))" -InputObject $exportFile
            } else {
                Add-Member -Membertype NoteProperty -Name 'filename' -value "joc-export.$($formats.Item($Format))" -InputObject $exportFile
            }

            Add-Member -Membertype NoteProperty -Name 'exportFile' -value $exportFile -InputObject $body

            $deployableDraftConfigurations = @()
            $deployableDeployedConfigurations = @()
            $releasableDraftConfigurations = @()
            $releasableReleasedConfigurations = @()

            $exportObjects.Keys | ForEach-Object { $object = $exportObjects.Item($_)
                if ( $object.area -eq 'deployable' -and $object.path -and $object.commitId -and $object.deployed )
                {
                    $deployedConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $deployedConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $deployedConfiguration
                    Add-Member -Membertype NoteProperty -Name 'commitId' -value $object.commitId -InputObject $deployedConfiguration

                    $deployedConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $deployedConfiguration -InputObject $deployedConfigurationItem

                    $deployableDeployedConfigurations += $deployedConfigurationItem
                } elseif ( $object.area -eq 'deployable' -and $object.path -and !$object.deployed ) {
                    $draftConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $draftConfiguration

                    if ( $object.type -eq 'FOLDER' )
                    {
                        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $draftConfiguration
                    }

                    $draftConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $draftConfiguration -InputObject $draftConfigurationItem

                    $deployableDraftConfigurations += $draftConfigurationItem
                } elseif ( $object.area -eq 'releasable' -and $object.path -and $object.released ) {
                    $releasedConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $releasedConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $releasedConfiguration

                    if ( $object.type -eq 'FOLDER' )
                    {
                        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $releasedConfiguration
                    }

                    $releasedConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $releasedConfiguration -InputObject $releasedConfigurationItem

                    $releasableReleasedConfigurations += $releasedConfigurationItem
                } elseif ( $object.area -eq 'releasable' -and $object.path -and !$object.released ) {
                    $draftConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $draftConfiguration

                    if ( $object.type -eq 'FOLDER' )
                    {
                        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $draftConfiguration
                    }

                    $draftConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $draftConfiguration -InputObject $draftConfigurationItem

                    $releasableDraftConfigurations += $draftConfigurationItem
                }
            }

            if ( $deployableDeployedConfigurations.count -or $deployableDraftConfigurations.count )
            {
                $deployablesObj = New-Object PSObject

                if ( $deployableDeployedConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployableDeployedConfigurations -InputObject $deployablesObj
                }

                if ( $deployableDraftConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $deployableDraftConfigurations -InputObject $deployablesObj
                }
            }


            if ( $releasableReleasedConfigurations.count -or $releasableDraftConfigurations.count )
            {
                $releasablesObj = New-Object PSObject

                if ( $releasableDraftConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $releasableDraftConfigurations -InputObject $releasablesObj
                }

                if ( $releasableReleasedConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'releasedConfigurations' -value $releasableReleasedConfigurations -InputObject $releasablesObj
                }
            }


            if ( $ForSigning )
            {
                $forSigningObj = New-Object PSObject

                if ( $ControllerId )
                {
                    Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $forSigningObj
                }

                if ( $deployablesObj )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployables' -value $deployablesObj -InputObject $forSigningObj
                }

                Add-Member -Membertype NoteProperty -Name 'forSigning' -value $forSigningObj -InputObject $body
            } elseif ( $deployablesObj -or $releasablesObj ) {
                $shallowCopyObj = New-Object PSObject

                if ( $ControllerId )
                {
                    Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $shallowCopyObj
                }

                if ( $deployablesObj )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployables' -value $deployablesObj -InputObject $shallowCopyObj
                }

                if ( $releasablesObj )
                {
                    Add-Member -Membertype NoteProperty -Name 'releasables' -value $releasablesObj -InputObject $shallowCopyObj
                }

                Add-Member -Membertype NoteProperty -Name 'shallowCopy' -value $shallowCopyObj -InputObject $body
            }

            if ( $deployablesObj -or $releasablesObj )
            {
                Add-Member -Membertype NoteProperty -Name 'withoutInvalid' -value ($Valid -eq $True) -InputObject $body

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
                $response = Invoke-JS7WebRequest -Path '/inventory/export' -Body $requestBody -Headers $headers -OutFile $FilePath

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
            } else {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items exported"
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
