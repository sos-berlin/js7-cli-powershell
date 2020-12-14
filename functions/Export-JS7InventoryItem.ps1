function Export-JS7InventoryItem
{
<#
.SYNOPSIS
Export inventory objects, e.g. workflows, schedules etc. from JOC Cockpit

.DESCRIPTION
This cmdlet exports inventory objects that are stored with JOC Cockpit. 

* Deployable Objects: use of the -Deployable parameter
** Inventory objects such as workflows are deployed to a JS7 Controller. The -Type parameter can be used to restrict object types.
** When exporting deployable objects then either a draft version can be used or the latest deployed version is requested by use of the -Deployed parameter.
* Releasable Objects: use of the -Releasable parameter
** Inventory objects such as calendars and schedules are not deployed to a Controller but are used by JOC Cockpit.
** When exporting releasable objects then either a draft version can be used or the latest released version is requested by use of the -Released parameter.

An export is performed either to backup deployable and releasable objects that later on can be imported (restored), 
or to export objects for signing and later depeloyment with a JOC Cockpit operated in security level "high".

The process to export for signigng includes the following steps:

* export deployable objects to a compressed archive (.zip, .tar.gz),
* unzip the archive to the local file system,
* manually sign objects,
* zip signed objects and signature files to a compressed archive,
* import the archive and deploy the signed objects.

.PARAMETER Path
Specifies the path and name of an individual inventory object that should be exported, e.g. a workflow.

.PARAMETER Type
Optionally restricts the object type to export which is one of: 

* Deployable Object Types
** WORKFLOW
** JOBCLASS
** LOCK
** JUNCTION
* Releasable Object Types
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE

The -Type parameter can be used to restrict either deployable or releasable object types to be exported.
Without specifying this parameter objects of any type within the areas of releasable or deployable objects are exported
depending on use of the -Releasable and -Deployable parameters.

.PARAMETER Folder
Optionally specifies the folder for which all included inventory objects should be exported. 
This parameter is used alternatively to the -Path parameter that specifies export of an individual inventory object.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be searched for exportable objects.

.PARAMETER Releasable
Specifies that only releasable objects should be exported that include the object types:

  * WORKINGDAYSCALENDAR
  * NONWORKINGDAYSCALENDAR
  * SCHEDULE

If none of the parameters -Releasable or -Deployable is used then both releasable and deployable inventory objects are exported.

.PARAMETER Deployable
Specifies that only deployable objects should be exported that include the object types:

  * WORKFLOW
  * JOBCLASS
  * LOCK
  * JUNCTION

If none of the parameters -Releasable or -Deployable is used then both releasable and deployable inventory objects are exported.

.PARAMETER Released
Specifies that no draft versions of the releasable objects will be exported but only released versions.
Without this parameter the unreleased draft version of inventory objects will be exported or the latest released version depending on availability.

.PARAMETER Deployed
Specifies that no draft versions of the deployable objects will be exported but only deployed versions.
Without this parameter the undeployed draft version of the inventory object will be exported or the latest deployed version depending on availability.

.PARAMETER Valid
Specifies that only valid versions of inventory objects are eligible for export. Only draft versions of 
inventory objects can be invalid, any deployed or relased versions of inventory objects are valid.
Without this parameter draft versions can be exported that are in progress and therefore are not validated.

.PARAMETER WithoutRemoved
Optionally specifies that no removed objects are added to the export. Such objects are marked for deletion, however,
deletion has not yet been confirmed by a deploy/release operation that permanently erases objects.

.PARAMETER ForSigning
Specifies that deployable objects are exported for external signing and later import into a JOC Cockpit
instance operated for security level "high". 

* The export file cannot include releasable objects as such objects are not subject to signing.
* The export file must be created from the same JOC Cockpit instance to which it will be imported for deployment.
* The process of export/signing/import must not exceed the max. idle time that is configured for a user's JOC Cockpit session.

Without this parameter the export file is created for backup purposes and can include any deployable and releasable objects.

.PARAMETER ControllerId
Specifies the ID of the Controller to which objects should be deployed after external signing.
This parameter is required if the -ForSigning parameter is used.

.PARAMETER FilePath
Specifies the path to the archive file that the exported inventory objects are written to.

If no file path is specified then an octet stream is returned by the cmdlet.

.PARAMETER ArchiveFormat
Specifies the type of the archive file that will be returned: ZIP, TAR.GZ.

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
This cmdlet returns an octet-stream that can be piped to an output file, e.g. with the Out-File cmdlet.

.EXAMPLE
Export-JS7InventoryItem | Out-File /tmp/export.zip

Exports all inventory objects to a zipped octet-stream that is written to a file. 
This includes deployable and releasable inventory objects.
By default draft versions are used instead of deployed or released versions.
If no draft version exists then the latest deployed or released version is used.

.EXAMPLE
Export-JS7InventoryItem -Folder /some_folder -FilePath /tmp/export.tar.gz -ArchiveFormat TAR.GZ

Exports any objects from the given folder to a compressed tar file.

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
Export-JS7InventoryItem -Folder /some_folder -Deployable -File /tmp/export.zip

Exports any deployable inventory objects such as workflows, junctions, locks etc that are available 
from the specified folder to a zipped file. The latest deployed version of the workflow is used.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBCLASS','LOCK','JUNCTION','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Releasable,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Deployable,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Released,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Deployed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $WithoutRemoved,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForSigning,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $FilePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ZIP','TAR.GZ')]
    [string] $ArchiveFormat = 'ZIP',
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

        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }
        
        if ( $Path -and $Folder -and ($Folder -ne '/') )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( $ForSigning -and !$ControllerId )
        {
            throw "$($MyInvocation.MyCommand.Name): if parameter -ForSigning is used then the -ControllerId parameter has to be specified."
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
        
        $deployableTypes = @('WORKFLOW','JOBCLASS','LOCK','JUNCTION')
        $releasableTypes = @('WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')
        $exportObjects = @()
        $deployablesObj = $null
        $releasablesObj = $null
    }
    
    Process
    {
        if ( $Folder -eq '/' -and !$Path -and !$Recursive )
        {
            $Recursive = $True
        }
        
        if ( !$Deployable -and !$Releasable )
        {
            $Deployable = $True
            $Releasable = $True
        }
        
        if ( $ForSigning )
        {
            $WithoutRemoved = $True
        }
        
        if ( $Deployable )
        {            
            if ( $Path )
            {
                $body = New-Object PSObject
                
                if ( !$Type )
                {
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $deployableTypes[0] -InputObject $body                    
                } else {
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
                }
                
                Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body                    
                Add-Member -Membertype NoteProperty -Name 'withVersions' -value ($Deployable -eq $True) -InputObject $body
                
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/deployable' -Body $requestBody
        
                if ( $response.StatusCode -eq 200 )
                {
                    $deployableObject = ( $response.Content | ConvertFrom-JSON ).deployable
                    
                    if ( !$deployableObject.id )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }                
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
                
                if ( !$deployableObject.deployablesVersions.count -or ( $deployableObject.deploymentId -ne $deployableObject.deployablesVersions[0].deploymentId ) )
                {
                    throw "$($MyInvocation.MyCommand.Name): could not find deployment for object: $Path"
                }

                if ( $deployableObject.deployablesVersions -and $deployableObject.deployablesVersions[0].commitId )
                {
                    $commitId = $deployableObject.deployablesVersions[0].commitId
                } else {
                    $commitId = $null
                }
                
                if ( $commitId )
                {
                    $exportObjects += @{ 'area' = 'deployable'; 'path' = $Path; 'type' = $Type[0]; 'deployed' = $deployableObject.deployed; 'commitId' = $commitId }
                } else {
                    $exportObjects += @{ 'area' = 'deployable'; 'path' = $Path; 'type' = $Type[0]; 'deployed' = $deployableObject.deployed }
                }
            } else {
                $body = New-Object PSObject

                if ( !$Type )
                {
                    Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $deployableTypes -InputObject $body                    
                } else {
                    Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
                }

                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body                                 
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body                    
                Add-Member -Membertype NoteProperty -Name 'withVersions' -value ($Deployable -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutRemovedObjects' -value ($WithoutRemoved -eq $True) -InputObject $body
                
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/deployables' -Body $requestBody
        
                if ( $response.StatusCode -eq 200 )
                {
                    $deployableObjects = ( $response.Content | ConvertFrom-JSON ).deployables                    
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
                
                foreach( $deployableObject in $deployableObjects )
                {
                    if ( $Deployed -eq $False -or $deployableObject.deployed )
                    {
                        if ( $deployableObject.deployablesVersions -and $deployableObject.deployablesVersions[0].commitId )
                        {
                            $commitId = $deployableObject.deployablesVersions[0].commitId
                        } else {
                            $commitId = $null
                        }

                        if ( $deployableObject.folder -and !$deployableObject.folder.endsWith( '/' ) )
                        {
                            $deployableObject.folder += '/'
                        }
                        
                        if ( $commitId )
                        {
                            $exportObjects += @{ 'area' = 'deployable'; 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'deployed' = $deployableObject.deployed ; 'commitId' = $deployableObject.deployablesVersions[0].commitId }
                        } else {
                            $exportObjects += @{ 'area' = 'deployable'; 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'deployed' = $deployableObject.deployed }                            
                        }
                    }
                }
            }
        }
        
        if ( $Releasable )
        {
            if ( $Path )
            {
                $body = New-Object PSObject

                if ( !$Type )
                {
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $releasableTypes[0] -InputObject $body                    
                } else {
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
                }

                Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body                    
                
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/releasable' -Body $requestBody
        
                if ( $response.StatusCode -eq 200 )
                {
                    $releasableObject = ( $response.Content | ConvertFrom-JSON ).releasable
                    
                    if ( !$releasableObject.id )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }                
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
                
                if ( $Released -eq $False -or $releasbleObject.released )
                {
                    if ( $releasableObject.folder -and !$releasableObject.folder.endsWith( '/' ) )
                    {
                        $releasableObject.folder += '/'
                    }
                
                    $exportObjects += @{ 'area' = 'releasable'; 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; 'released' = $releasableObject.released }                
                }
            } else {
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
                Add-Member -Membertype NoteProperty -Name 'withoutRemovedObjects' -value ($WithoutRemoved -eq $True) -InputObject $body
                
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/releasables' -Body $requestBody
        
                if ( $response.StatusCode -eq 200 )
                {
                    $releasableObjects = ( $response.Content | ConvertFrom-JSON ).releasables
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
                
                foreach( $releasableObject in $releasableObjects )
                {
                    if ( $Released -eq $False -or $releasbleObject.released )
                    {
                        if ( $releasableObject.id )
                        {
                            if ( $releasableObject.folder -and !$releasableObject.folder.endsWith( '/' ) )
                            {
                                $releasableObject.folder += '/'
                            }
                        
                            $exportObjects += @{ 'area' = 'releasable'; 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; ; 'released' = $releasableObject.released }
                        }
                    }
                }
            }
        }
    }

    End
    {
        if ( $exportObjects.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'forSigning' -value ($ForSigning -eq $True) -InputObject $body

            $exportFile = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'archiveFormat' -value "$ArchiveFormat" -InputObject $exportFile

            if ( $FilePath )
            {
                Add-Member -Membertype NoteProperty -Name 'exportFile' -value "$([System.IO.Path]::GetFileName($FilePath))" -InputObject $exportFile
            } else {
                Add-Member -Membertype NoteProperty -Name 'exportFile' -value "joc-export$($ArchiveFormat)" -InputObject $exportFile
            }

            Add-Member -Membertype NoteProperty -Name 'exportFile' -value $exportFile -InputObject $body


            $deployableDraftConfigurations = @()
            $deployableDeployedConfigurations = @()
            $releasableDraftConfigurations = @()
            $releasableReleasedConfigurations = @()
            
            foreach( $object in $exportObjects )
            {                
                if ( $object.area -eq 'deployable' -and $object.deployed )
                {
                    $deployedConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $deployedConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $deployedConfiguration
                    Add-Member -Membertype NoteProperty -Name 'commitId' -value $object.commitId -InputObject $deployedConfiguration

                    $deployedConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'deployConfiguration' -value $deployedConfiguration -InputObject $deployedConfigurationItem

                    $deployableDeployedConfigurations += $deployedConfigurationItem
                } elseif ( $object.area -eq 'deployable' -and !$object.deployed ) {
                    $draftConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $draftConfiguration

                    $draftConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'draftConfiguration' -value $draftConfiguration -InputObject $draftConfigurationItem

                    $deployableDraftConfigurations += $draftConfigurationItem
                } elseif ( $object.area -eq 'releasable' -and $object.released ) {
                    $releasedConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $releasedConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $releasedConfiguration

                    $releasedConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'deployConfiguration' -value $releasedConfiguration -InputObject $releasedConfigurationItem

                    $releasableReleasedConfigurations += $releasedConfigurationItem
                } elseif ( $object.area -eq 'releasable' -and !$object.released ) {
                    $draftConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $draftConfiguration

                    $draftConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'draftConfiguration' -value $draftConfiguration -InputObject $draftConfigurationItem

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
                
                Add-Member -Membertype NoteProperty -Name 'deployables' -value $deployablesObj -InputObject $body
            }

            
            if ( $releasableReleasedConfigurations.count -or $releasableDraftConfigurations.count )
            {                
                $releasablesObj = New-Object PSObject

                if ( $releasableReleasedConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $releasableReleasedConfigurations -InputObject $releasablesObj
                }
                
                if ( $releasableDraftConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $releasableDraftConfigurations -InputObject $releasablesObj
                }
                
                Add-Member -Membertype NoteProperty -Name 'releasables' -value $releasablesObj -InputObject $body
            }


            if ( $forSigningObj )
            {
                $forSigningObj = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $forSigningObj

                if ( $deployablesObj )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployables' -value $deployablesObj -InputObject $forSigningObj
                }

                Add-Member -Membertype NoteProperty -Name 'forSigning' -value $forSigningObj -InputObject $body
            } else {
                $forBackupObj = New-Object PSObject

                if ( $deployablesObj )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployables' -value $deployablesObj -InputObject $forBackupObj                    
                }

                if ( $rleasablesObj )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployables' -value $releasablesObj -InputObject $forBackupObj                    
                }

                Add-Member -Membertype NoteProperty -Name 'forBackup' -value $forBackupObj -InputObject $body
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

            $headers = @{'Accept' = 'application/octet-stream'; 'Accept-Encoding' = 'gzip, deflate' }       

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/export' -Body $requestBody -Headers $headers
            
            if ( $response.StatusCode -ne 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $FilePath )
            {
                [System.Text.Encoding]::ASCII.GetString( $response.Content ) | Out-File $FilePath
            } else {
                [System.Text.Encoding]::ASCII.GetString( $response.Content )                
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($exportObjects.count) objects exported"                
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no objects exported"                
        }

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
