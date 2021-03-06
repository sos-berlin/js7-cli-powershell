function Publish-JS7DeployableItem
{
<#
.SYNOPSIS
Deploys a configuration object such as a workflow to a number of JS7 Controllers.

.DESCRIPTION
This cmdlet deploys a configuration object to a number of JS7 Controllers. Consider a workflow
that can be deployed to more than one Controller.

Deployment includes that objects such as workflows are digitally signed and forwarded to a Controller.
Depending on the security level JOC Cockpit is operated for signging is available with a general certificate,
with a user based certificate or by external signing.

Deployment can include to permanently delete previously removed objects from Controllers and from the inventory.
Therefore, if a deployable object is removed, e.g. with the Remove-JS7InventoryItem cmdlet, then this removal has to
be committed using this cmdlet for deployment.

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, e.g. a workflow path.

.PARAMETER Type
Specifies the object type which is one of:

* FOLDER
* WORKFLOW
* JOBCLASS
* JOBRESOURCE
* LOCK
* JUNCTION
* FILEORDERSOURCE

.PARAMETER Folder
Optionally specifies the folder for which included inventory objects should be published.
This parameter is used alternatively to the -Path parameter that specifies to publish an individual inventory object.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up. By default no sub-folders will be considered.

.PARAMETER ControllerId
Specifies one or more Controllers to which the indicated objects should be deployed.

.PARAMETER Delete
Specifies the action to permanently delete objects from a Controller. Without this switch objects
are published for use with a Controller.

.PARAMETER NoDraft
Specifies that no draft objects should be deployed. This boils down to the fact that only previously deployed objects will be deployed.
Possible use cases include to deploy to a different Controller or to redeploy to the same Controller.

.PARAMETER NoDeployed
Specifies that no previously deployed objects should be deployed. This is usefule to prevent redeployment of objects.

.PARAMETER Latest
If used with the -Path parameter then -Latest specifies that only the latest deployed object will be considered for redeployment.
This parameter is not considered if the -NoDeployed parameter is used.

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
This cmdlet accepts pipelined objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite,standalone -Path /TestCases/sampleWorkflow_001 -Type 'WORKFLOW'

Deploys the specified workflow from the indicated path to both Controller instances.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite -Path /TestCases/sampleWorkflows -Type 'FOLDER' -Delete

Deletes the specified folder from the inventory and deletes any included deployable objects such as workflows from the indicated Controller and inventory.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite -Folder /PowerShell -Delete

Deletes any deployable objects such as workflows from the specified folder recursively.
Consider that the specified folder is not deleted but its contents only.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite -Path /PowerShell -Type FOLDER -Delete

Deletes any deployable objects such as workflows from the specified folder recursively.
Consider that the specified folder is not deleted but its contents only.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('FOLDER','WORKFLOW','JOBCLASS','JOBRESOUROCE','LOCK','JUNCTION','FILEORDERSOURCE')]
    [string[]] $Type = 'FOLDER',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Delete,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDeployed,
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

        $controllerIds = @()
        $storeObjects = @()
        $deleteObjects = @()

        $deployableTypes = @('FOLDER','WORKFLOW','JOBCLASS','JOBRESOURCE','LOCK','JUNCTION','FILEORDERSOURCE')
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

        if ( $Path -and $Folder -and ($Folder -ne '/') )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( !$Path -and !$Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -Path or -Folder has to be used"
        }

        if ( $Folder -eq '/' -and !$Path -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( !$Path )
        {
            $Path = $Folder
        }

        if ( $Type )
        {
            for( $i=0; $i -lt $Type.length; $i++ )
            {
                if ( $deployableTypes -notcontains $Type[$i] )
                {
                    throw "$($MyInvocation.MyCommand.Name): value of -Type parameter not allowed ($($deployableTypes)): $($Type[$i])"
                } else {
                    $Type[$i] = $Type[$i].toUpper()
                }
            }
        }

        if ( !$Type )
        {
            $Type = $deployableTypes
        }

        if ( $Path )
        {
            if ( $Type[0] -eq 'FOLDER' )
            {
                if ( $Delete )
                {
                    $deleteObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $True; 'deployed' = ($NoDeployed -eq $False) }
                } else {
                    $storeObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $True; 'deployed' = ($NoDeployed -eq $True) }
                }
            } else {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value $True -InputObject $body
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

                if ( $Delete )
                {
                    $deleteObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed }
                } else {
                    $storeObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed }
                }
            }
        } else {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value $False -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'latest' -value ($Latest -eq $True) -InputObject $body

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/deployables' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $deployableObjects = ( $response.Content | ConvertFrom-Json ).deployables
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            foreach( $deployableObject in $deployableObjects )
            {
                if ( $deployableObject.objectType -eq 'FOLDER' )
                {
                    if ( $Delete )
                    {
                        $deleteObjects += @{ 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $True }
                    } else {
                        $storeObjects += @{ 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $False }
                    }

                    continue
                }

                if ( $deployableObject.folder -and !$deployableObject.folder.endsWith( '/' ) )
                {
                    $deployableObject.folder += '/'
                }

                if ( $Delete )
                {
                    $deleteObjects += @{ 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed }
                } else {
                    $storeObjects += @{ 'path' = "$($deployableObject.folder)$($deployableObject.objectName)"; 'type' = $deployableObject.objectType; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed }
                }
            }
        }

        if ( $ControllerId )
        {
            $controllerIds += $ControllerId
        }
    }

    End
    {
        if ( $storeObjects.count -or $deleteObjects.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $body

            $draftConfigurations = @()
            $deployConfigurations = @()
            foreach( $object in $storeObjects )
            {
                if ( !$object.valid )
                {
                    throw "$($MyInvocation.MyCommand.Name): invalid object selected for deployment: path=$($object.path), type=$($object.type)"
                }

                if ( $object.deployed )
                {
                    $deployConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $deployConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $deployConfiguration
                    Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $deployConfiguration
                    # Add-Member -Membertype NoteProperty -Name 'commitId' -value $object.commitId -InputObject $deployConfiguration

                    $deployConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $deployConfiguration -InputObject $deployConfigurationItem

                    $deployConfigurations += $deployConfigurationItem
                } else {
                    $draftConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $draftConfiguration
                    Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $draftConfiguration

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

                Add-Member -Membertype NoteProperty -Name 'store' -value $storeObject -InputObject $body
            }

            $deployConfigurations = @()
            foreach( $object in $deleteObjects )
            {
                if ( $object.deployed )
                {
                    $deployConfiguration = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $deployConfiguration
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $deployConfiguration

                    $deployConfigurationItem = New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'configuration' -value $deployConfiguration -InputObject $deployConfigurationItem

                    $deployConfigurations += $deployConfigurationItem
                }
            }

            if ( $deployConfigurations.count )
            {
                $deleteObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployConfigurations -InputObject $deleteObject
                Add-Member -Membertype NoteProperty -Name 'delete' -value $deleteObject -InputObject $body
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
            $response = Invoke-JS7WebRequest -Path '/inventory/deployment/deploy' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($storeObjects.count + $deleteObjects.count) objects deployed"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no objects deployed"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
