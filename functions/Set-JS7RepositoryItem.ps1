function Set-JS7RepositoryItem
{
<#
.SYNOPSIS
Stores scheduling objects from the JS7 inventory to a local Git repository

.DESCRIPTION
This cmdlet stores JS7 scheduling objects to a local Git repository. The JS7 settings
determine which object types such as schedules, workflows are considered for a repository
of category LOCAL and of category ROLLOUT respectively.

The following REST Web Service API resources are used:

* /inventory/deployable
* /inventory/deployables
* /inventory/releasable
* /inventory/releasables
* /inventory/repository/store

.PARAMETER Path
Specifies the folder, sub-folder and name of the scheduling object, for example a workflow path,
that should be stored to the repository.

.PARAMETER Type
Specifies the scheduling object type that is one or more of:

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
** REPORT

If no object type is specified then any object types will be used.

.PARAMETER Folder
Alternatively to use of -Path the parameter specifies a JOC Cockpit inventory folder to be used to
store objects to a local Git repository.

.PARAMETER Recursive
Specifies that all sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be looked up.

.PARAMETER ControllerId
Optionally limits the selection of deployed scheduling objects to the Controller indicated with the Controller ID.
Objects that are deployed to other Controllers will not be stored to the repository.

.PARAMETER Local
Specifies that a repository holding scheduling objects that are local to the environment should be used.
This corresponds to the LOCAL category. If this switch is not used then the
ROLLOUT category is assumed for a repository that holds scheduling objects
intended for rollout to later environments such as test, prod.

.PARAMETER Valid
Limits the scope to valid schedudling objects only.

.PARAMETER NoDraft
Specifies that no draft objects should be stored. This boils down to the fact
that only previously deployed or released objects will be stored.

.PARAMETER NoDeployed
Specifies that no previously deployed objects should be stored.

.PARAMETER NoReleased
Specifies that no previously released objects should be stored.

.PARAMETER Latest
If used with the -Path parameter then -Latest specifies that only the latest deployed object will be considered.
This parameter is not considered if the -NoDeployed parameter is used.

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
This cmdlet returns no output.

.EXAMPLE
Set-JSRepositoryItem -Folder /TestCases/sampleWorkflows -Recursive

Stores any scheduling objects of the indicated folder and sub-folders to the repository of category ROLLOUT.

.EXAMPLE
Set-JS7RepositoryItem -ControllerId testsuite,standalone -Path /TestCases/sampleWorkflow_001 -Type 'WORKFLOW'

Stores the workflow from the specified path to the local repository of category ROLLOUT provided that
the workflow has previously been deployed to both indicated Controller instances.

.EXAMPLE
Set-JS7RepositoryItem -ControllerId testsuite -Folder /Samples -NoDraft

Stores any objects such as workflows, resource locks etc from the specified folder
to the repository of category ROLLOUT. No sub-folders and no draft versions of objects are considered.

.EXAMPLE
Set-JS7RepositoryItem -ControllerId testsuite -Folder /Samples -Recursive -Local

Stores any objects such as job resources and schedules from the specified folder recursively
to the repository of category LOCAL. Deployable objects are considered only if
previously deployed to the indicated Controller.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','REPORT',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Local,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDeployed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReleased,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Latest,
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

        $storeObjects = @()
        $deployableTypes = @('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK')
        $releasableTypes = @('INCLUDESCRIPT','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')

        if (IsJOCVersion -Major 2 -Minor 7 -Patch 1 )
        {
            $releasableTypes += 'REPORT'
        }
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

        if ( $Folder -and $Type.count -eq 0 )
        {
            $Type = $deployableTypes
            $Type += $releasableTypes
        }

        if ( $Path )
        {
            $curType = $Type[0]

            if ( $deployableTypes.contains( $curType ) )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0].toUpper() -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
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

                if ( $deployableObject.deployablesVersions.count )
                {
                    $commitId = $deployableObject.deployablesVersions[0].commitId
                } else {
                    $commitId = $Null
                }

                $storeObjects += @{ 'path' = $Path; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed; 'commitId' = $commitId }
            } elseif ( $releasableTypes.contains( $curType ) ) {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $curType -InputObject $body
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

                $storeObjects += @{ 'path' = $Path; 'type' = $curType; 'valid' = $releasableObject.valid; 'released' = $releasableObject.released }
            } else {
                throw "$($MyInvocation.MyCommand.Name): unknown type: $curType"
            }
        } else {
            if ( $Type.count )
            {
                $lookupDeployableTypes = @()
                $lookupReleasableTypes = @()
                for( $i=0; $i -lt $Type.length; $i++ )
                {
                    if ( $deployableTypes -contains $Type[$i] )
                    {
                        $lookupDeployableTypes += $Type[$i]
                    } elseif ( $releasableTypes -contains $Type[$i] ) {
                        $lookupReleasableTypes += $Type[$i]
                    } else {
                        throw "$($MyInvocation.MyCommand.Name): check types: unknown type: $($Type[$i])"
                    }
                }
            } else {
                $lookupDeployableTypes = $deployableTypes
                $lookupReleasableTypes = $releasableTypes
            }

            if ( $lookupDeployableTypes )
            {
                $body = New-Object PSObject

                if ( $ControllerId )
                {
                    Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
                }

                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $lookupDeployableTypes -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'latest' -value ($Latest -eq $True) -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/deployables' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $deployableItems = ( $response.Content | ConvertFrom-Json )
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                if ( $deployableItems.folders )
                {
                    $deployableObjects = $deployableItems.folders.deployables
                } else {
                    $deployableObjects = $deployableItems.deployables
                }

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($deployableObjects.count) deployable objects found"

                foreach( $deployableObject in $deployableObjects )
                {
                    if ( $deployableObject.objectType -eq 'FOLDER' )
                    {
                        $storeObjects += @{ 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $False }
                        continue
                    }

                    if ( $deployableObject.folder -and !$deployableObject.folder.endsWith( '/' ) )
                    {
                        $deployableObject.folder += '/'
                    }

                    if ( $deployableObject.deployablesVersions.count )
                    {
                        $commitId = $deployableObject.deployablesVersions[0].commitId
                    } else {
                        $commitId = $Null
                    }
                    if ( $deployableObject.objectName )
                    {
                        $storeObjects += @{ 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed; 'commitId' = $commitId }
                    }
                }
            }

            if ( $lookupReleasableTypes )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $lookupReleasableTypes -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'withoutReleased' -value ($NoReleased -eq $True) -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/releasables' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $releasableItems = ( $response.Content | ConvertFrom-Json )
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                if ( $releasableItems.folders )
                {
                    $releasableObjects = $releasableItems.folders.releasables
                } else {
                    $releasableObjects = $releasableItems.releasables
                }

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($releasableObjects.count) releasable objects found"

                foreach( $releasableObject in $releasableObjects )
                {
                    if ( $releasableObject.folder -and !$releasableObject.folder.endsWith( '/' ) )
                    {
                        $releasableObject.folder += '/'
                    }

                    if ( $releasableObject.objectName )
                    {
                        $storeObjects += @{ 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; 'valid' = $releasableObject.valid; 'released' = $releasableObject.released }
                    }
                }
            }
        }
    }

    End
    {
        if ( $storeObjects.count )
        {
            if ( $Local )
            {
                $category = 'local'
            } else {
                $category = 'rollout'
            }

            $body = New-Object PSObject

            if ( $ControllerId )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            }

            $draftConfigurations = @()
            $deployConfigurations = @()

            foreach( $object in $storeObjects )
            {
                if ( $object.deployed )
                {
                    $deployConfiguration = New-Object PSObject

                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $deployConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $deployConfiguration

                    if ( $object.type -eq 'FOLDER' )
                    {
                        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $deployConfiguration
                    }

                    if ( $object.commitId )
                    {
                        Add-Member -Membertype NoteProperty -Name 'commitId' -value $object.commitId -InputObject $deployConfiguration
                    }

                    $deployConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $deployConfiguration -InputObject $deployConfigurationItem

                    $deployConfigurations += $deployConfigurationItem
                } else {
                    $draftConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $draftConfiguration

                    if ( $object.type -eq 'FOLDER' )
                    {
                        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $draftConfiguration
                    }

                    $draftConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $draftConfiguration -InputObject $draftConfigurationItem

                    $draftConfigurations += $draftConfigurationItem
                }
            }

            if ( $deployConfigurations.count -or $draftConfigurations.count )
            {
                $storeObject = New-Object PSObject

                if ( $draftConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value $draftConfigurations -InputObject $storeObject
                }

                if ( $deployConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployConfigurations -InputObject $storeObject
                }

                Add-Member -Membertype NoteProperty -Name $category -value $storeObject -InputObject $body
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

            if ( $PSCmdlet.ShouldProcess( 'set repository item', '/inventory/repository/store' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/repository/store' -Body $requestBody

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
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($storeObjects.count) items stored"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items stored"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
