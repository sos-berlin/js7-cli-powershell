function Publish-JS7DeployableItem
{
<#
.SYNOPSIS
Deploys scheduling objects such as workflows to JS7 Controllers

.DESCRIPTION
This cmdlet deploys scheduling objects to a number of JS7 Controllers. Consider for example a workflow
that can be deployed to more than one Controller.

Deployment includes that objects such as workflows are digitally signed and are forwarded to a Controller.
Depending on the security level in use signing is available with a common private key/certificate (security level: LOW),
with a user based private key/certificate (security level: MEDIUM) or by external signing (security level: HIGH).

Deployment can include to permanently delete previously removed objects from Controllers and from the inventory.
Therefore, if a deployable object is removed, e.g. with the Remove-JS7InventoryItem cmdlet, then this removal has to
be committed using this cmdlet for deployment.

The following REST Web Service API resources are used:

* /inventory/deployable
* /inventory/deployables
* /inventory/deploy

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, for example a workflow path.

.PARAMETER Type
Specifies the object type which is one of:

* WORKFLOW
* FILEORDERSOURCE
* JOBRESOURCE
* NOTICEBOARD
* LOCK

.PARAMETER Folder
Optionally specifies the folder from which included inventory objects should be published.
This parameter is used alternatively to the -Path parameter that specifies to publish an individual inventory object.

.PARAMETER Recursive
Specifies that all sub-folders should be looked up. By default no sub-folders will be considered.

.PARAMETER Change
Specifies the identifier of an inventory change. Scheduling objects indicated with the change and
dependencies will be deployed.

If in addition the -Folder parameter is used, then scheduling objects of the change will be limited
to objects located in the specified folder.

.PARAMETER ControllerId
Specifies one or more Controllers to which the indicated objects should be deployed.

.PARAMETER UpdateDailyPlanFrom
Specifies the Daily Plan date starting from which orders from the Daily Plan should be updated to use the latest deployed version of a workflow.

This parameter can be used alternatively to -UpdateDailyPlanNow. If none of the parameters is specified, then the Daily Plan will not be updated.

.PARAMETER UpdateDailyPlanNow
Specifies that any scheduled orders from the Daily Plan should be updated to use the latest deployed version of a workflow.

This parameter can be used alternatively to -UpdateDailyPlanFrom. If none of the parameters is specified, then the Daily Plan will not be updated.

.PARAMETER Delete
Specifies the action to permanently delete objects from a Controller. Without this switch objects
are published for use with a Controller.

.PARAMETER Valid
Limits the scope to valid scheduling objects only.

.PARAMETER NoDraft
Specifies that no draft objects should be deployed. This boils down to the fact that only previously deployed objects will be deployed.
Possible use cases include to deploy to a different Controller or to redeploy to the same Controller.

.PARAMETER NoDeployed
Specifies that no previously deployed objects should be deployed. This is useful for preventing redeployment of objects.

.PARAMETER Latest
If used with the -Path parameter then -Latest specifies that only the latest deployed object will be considered for redeployment.
This parameter is not considered if the -NoDeployed parameter is used.

.PARAMETER NoReferencing
Specifies that no referencing objects from dependencies of objects subject to the indicated -Change should be included.

.PARAMETER NoReferences
Specifies that no references to objects from dependencies of objects subject to the indicated -Change should be included.

.PARAMETER ObjectName
Internal use for pipelining.

.PARAMETER ObjectType
Internal use for pipelining.

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
This cmdlet accepts pipelined objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite -Folder /TestCases/sampleWorkflows -Recursive

Deploys any scheduling objects such as workflows from the specified folder and any sub-folders to the indicated Controllers.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite -Folder /TestCases/sampleWorkflows -Recursive -Delete

Marks for deletion any scheduling objects such as workflows from the specified folder and any sub-folders.
Consider that the specified folder is not deleted but its contents only.

.EXAMPLE
Publish-JS7DeployableItem -ControllerId testsuite,standalone -Path /TestCases/sampleWorkflow_001 -Type 'WORKFLOW'

Deploys the specified workflow from the indicated path to both Controller instances.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Change,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $UpdateDailyPlanFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $UpdateDailyPlanNow,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Delete,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDeployed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Latest,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReferencing,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReferences,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK',IgnoreCase = $False)]
    [string] $ObjectType,
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

        if ( $UpdateDailyPlanFrom -and $UpdateDailyPlanNow )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -UpdateDailyPlanFrom and -UpdateDailyPlanNow can be used"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $objectCount = 0
        $changes = @()
        $controllerIds = @()
        $storeObjects = @()
        $deleteObjects = @()

        $deployableTypes = @('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK')
    }

    Process
    {
        While ( $Folder.endsWith('/') )
        {
            $Folder = $Folder.Substring( 0, $Folder.Length -1 )
        }

        if ( $ObjectType )
        {
            $Type = @( $ObjectType )
        }

        if ( $ObjectName -and $Folder )
        {
            $Path = "$Folder/$ObjectName"
            $Folder = $null
        }

        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }

        if ( $Path -and !$Type.count )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify the object type, use -Type parameter"
        }

        if ( $Path -and ($Type.count -gt 1) )
        {
            throw "$($MyInvocation.MyCommand.Name): path requires to specify only one object type, use -Type parameter"
        }

        if ( $Path -and $Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Folder can be used"
        }

        if ( $Path -and $Change )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Path or -Change can be used"
        }

        if ( !$Path -and !$Folder -and !$Change )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -Path, -Folder or -Change has to be used"
        }

        if ( $Type.count )
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
        } else {
            $Type = $deployableTypes
        }

        if ( $Change )
        {
            $changes += $Change
        } elseif ( $Path ) {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type[0] -InputObject $body
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

            if ( $Delete )
            {
                $deleteObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed }
            } else {
                $storeObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $deployableObject.valid; 'deployed' = $deployableObject.deployed }
            }
        } else {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
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

            $deployableObjects = $deployableItems.deployables

            if ( $deployableItems.folders )
            {
                $deployableObjects += $deployableItems.folders.deployables
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
        if ( $changes.count )
        {
            $changeItems = Get-JS7InventoryChange -Name $changes -Detailed

            if ( !$changeItems )
            {
                throw "$($MyInvocation.MyCommand.Name): no changes found"
            }

            if ( $Folder.count )
            {
                $configurations = Get-JS7ConfigurationMerge -ChangeItems $changeItems -Dependencies (Get-JS7InventoryDependencies -OperationType DEPLOY -Folder $Folder -Configuration $changeItems.configurations -NoReferencing:$NoReferencing -NoReferences:$NoReferences)
            } else {
                $configurations = Get-JS7ConfigurationMerge -ChangeItems $changeItems -Dependencies (Get-JS7InventoryDependencies -OperationType DEPLOY -Configuration $changeItems.configurations -NoReferencing:$NoReferencing -NoReferences:$NoReferences)
            }

            $body = New-Object PSObject
            $deployableConfigurations = @($configurations | Where-Object { $_.configuration.objectType -in $deployableTypes })

            if ( $deployableConfigurations.count )
            {
                $deployableDraftConfiguration = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'draftConfigurations' -value ([PSObject[]] $deployableConfigurations) -InputObject $deployableDraftConfiguration

                $objectCount += $deployableConfigurations.configuration.count
                Add-Member -Membertype NoteProperty -Name 'store' -value $deployableDraftConfiguration -InputObject $body
            }

            if ( $controllerIds )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $body
            }
        } elseif ( $storeObjects.count -or $deleteObjects.count ) {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $body

            if ( $UpdateDailyPlanNow )
            {
                Add-Member -Membertype NoteProperty -Name 'addOrdersDateFrom' -value 'now' -InputObject $body
            } elseif ( $UpdateDailyPlanFrom ) {
                Add-Member -Membertype NoteProperty -Name 'addOrdersDateFrom' -value (Get-Date $UpdateDailyPlanFrom -Format 'yyyy-MM-dd') -InputObject $body
            }

            $draftConfigurations = @()
            $deployConfigurations = @()

            foreach( $object in $storeObjects )
            {
                if ( !$object.path )
                {
                    continue
                }

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
                    $objectCount += $draftConfigurations.count
                }

                if ( $deployConfigurations.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployConfigurations -InputObject $storeObject
                    $objectCount += $deployConfigurations.count
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
                $objectCount += $deployConfigurations.count
                $deleteObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'deployConfigurations' -value $deployConfigurations -InputObject $deleteObject
                Add-Member -Membertype NoteProperty -Name 'delete' -value $deleteObject -InputObject $body
            }
        }

        if ( $objectCount )
        {
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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($objectCount) items deployed"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items deployed"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
