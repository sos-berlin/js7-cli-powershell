function Export-JS7Object
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

.PARAMETER FileType
Specifies the type of the archive file that will be returned: .zip, .tar.gz or .gz.

If the -FilePath parameter is specified then the extension of the file name will be used for the file type.

.PARAMETER FilePath
Specifies the path to the output file that the exported inventory objects are written to.

If no output file is specified then an octet stream is returned by the cmdlet.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforece Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined objects that are returned e.g. from the Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns an octet-stream that can be piped to an output file, e.g. with the Out-File cmdlet.

.EXAMPLE
Export-JS7Object | Out-File /tmp/export.zip -Encoding UTF8

Exports all inventory objects to a zipped file. This includes deployable and releasable inventory objects.
By default draft versions are used instead of deployed or released versions.
If no draft version exists then the latest deployed or released version is used.

.EXAMPLE
Export-JS7Object -Folder /some_folder -File /tmp/export.zip

Exports any objects from the given folder to a zipped file.

.EXAMPLE
Export-JS7Object -Folder /some_folder -Deployable -File /tmp/export.zip

Exports deployable objects only from the given folder to a zipped file.

.EXAMPLE
Export-JS7Object -Path /some_folder/some_workflow -Type WORKFLOW -File /tmp/export.zip

Exports the specified workflow from the indcated path to a zipped file. 
Use of the -Path parameter requires to specify the -Type parameter for the object type.

Depending on availability the draft version or the latest deployed version of the workflow is used.
If a draft version is available then it is eligible for export independent from the fact that the draft is valid or invalid.

.EXAMPLE
Export-JS7Object -Path /some_folder/some_workflow -Type WORKFLOW -Valid -File /tmp/export.zip

Exports the specified workflow from the indcated path to a zipped file. 
Use of the -Path parameter requires to specify the -Type parameter for the object type.

Depending on availability the draft version or the latest deployed version of the workflow is used.
A draft version is considered only if it is valid otherwise the deployed version is used.

.EXAMPLE
Export-JS7Object -Folder /some_folder -Deployable -File /tmp/export.zip

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
    [switch] $ForSigning,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('.zip','.tar.gz','.gz')]
    [string] $Filetype = '.zip',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Filepath,
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
        
        if ( $Path -and !$Type )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify the object type, use -Type parameter"
        }
        
        if ( $Path -and $Folder -and ($Folder -ne '/') )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( $ForSigning -and !$ControllerId )
        {
            throw "$($MyInvocation.MyCommand.Name): if parameter -ForSigning is used then the -ControllerId parameter has to be specified."
        }

        if ( $FilePath -and !$FilePath.endsWith('.zip') -and !$FilePath.endsWith('.tar.gz') -and !$FilePath.endsWith('.gz') )
        {
            throw "$($MyInvocation.MyCommand.Name): unsupported value for -FileType parameter specified, use .zip, .tar.gz or .gz."
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
        
        $deployableTypes = @('WORKFLOW','JOBCLASS','LOCK','JUNCTION')
        $releasableTypes = @('WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')
        $exportObjects = @()
    }
    
    Process
    {
        if ( $Folder -eq '/' -and !$Path -and !$Recursive )
        {
            $Recursive = $True
        }
        
        if ( $FilePath )
        {
            $FileType = [System.IO.Path]::GetExtension($FilePath)
        }
        
        if ( !$Deployable -and !$Releasable )
        {
            $Deployable = $True
            $Releasable = $True
        }
        
        if ( $Deployable )
        {
            if ( !$Type )
            {
                $Type = $deployableTypes
            }
            
            if ( $Path )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
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
                
                # if ( $Deployed -eq $False -or $deployableObject.deployed )
                if ( $commitId )
                {
                    $exportObjects += @{ 'area' = 'deployable'; 'path' = $Path; 'type' = $Type[0]; 'deployed' = $deployableObject.deployed; 'commitId' = $commitId }
                } else {
                    $exportObjects += @{ 'area' = 'deployable'; 'path' = $Path; 'type' = $Type[0]; 'deployed' = $deployableObject.deployed }
                }
            } else {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body                                    
                Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body                    
                Add-Member -Membertype NoteProperty -Name 'withVersions' -value ($Deployable -eq $True) -InputObject $body
                
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
                        
#                       if ( $deployableObject.deployablesVersions.count -and ( $deployableObject.deploymentId -eq $deployableObject.deployablesVersions[0].deploymentId ) )
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
            if ( !$Type )
            {
                $Type = $releasableTypes
            }

            if ( $Path )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
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
                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body                                    
                Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body                    
                
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/releasables' -Body $requestBody
        
                if ( $response.StatusCode -eq 200 )
                {
                    $releasableObjects = ( $response.Content | ConvertFrom-JSON ).releasables
                    
                    if ( !$releasableObjects.deliveryDate )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }                
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
            
            if ( $ForSigning )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            }
            
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
                } else {
                    # Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployableDeployedConfigurations -InputObject $deployablesObj
                }
                
                if ( $deployableDraftConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $deployableDraftConfigurations -InputObject $deployablesObj
                } else {
                    # Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $deployableDraftConfigurations -InputObject $deployablesObj                    
                }
                
                Add-Member -Membertype NoteProperty -Name 'deployables' -value $deployablesObj -InputObject $body
            }

            
            if ( $releasableReleasedConfigurations.count -or $releasableDraftConfigurations.count )
            {                
                $releasablesObj = New-Object PSObject

                if ( $releasableReleasedConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $releasableReleasedConfigurations -InputObject $releasablesObj
                } else {
                    # Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $releasableReleasedConfigurations -InputObject $releasablesObj
                }
                
                if ( $releasableDraftConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $releasableDraftConfigurations -InputObject $releasablesObj
                } else {
                    # Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $releasableDraftConfigurations -InputObject $releasablesObj                    
                }
                
                Add-Member -Membertype NoteProperty -Name 'releasables' -value $releasablesObj -InputObject $body
            }
            
            if ( $FilePath )
            {
                Add-Member -Membertype NoteProperty -Name 'filename' -value "$([System.IO.Path]::GetFileName($FilePath))" -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'filename' -value "joc-export$($FileType)" -InputObject $body                
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
       

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/export' -Body $requestBody
            
            if ( $response.StatusCode -ne 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $FilePath )
            {
                [System.Text.Encoding]::UTF8.GetString( $response.Content ) | Out-File $FilePath -Encoding UTF8
            } else {
                [System.Text.Encoding]::UTF8.GetString( $response.Content )                
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): objects exported"                
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no objects exported"                
        }

        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
