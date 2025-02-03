function Get-JS7InventoryDependencies
{
<#
.SYNOPSIS
Returns dependencies from the JOC Cockpit inventory

.DESCRIPTION
Dependencies are returned from the JOC Cockpit inventory per scheduling object
that is specified by its name and type.

The cmdlet returns the list of inventory objects that

* are referencing the requested scheduling object
* are referenced by the requested scheduling object

Resulting objects can be forwarded to other cmdlets for pipelined bulk operations.

The following REST Web Service API resources are used:

* /inventory/dependencies

.PARAMETER OperationType
Specifies the purpose of the list of objects that will be returned.
The operation type is one of:

* DEPLOY
* RELEASE
* REVOKE
* RECALL
* REMOVE
* EXPORT
* GIT

.PARAMETER Name
Specifies the name of the scheduling object for which dependencies should be returned.

.PARAMETER Type
Specifies the type of the scheduling object for which dependencies should be returned.
The object type is one of:

* WORKFLOW
* JOBRESOURCE
* LOCK
* NOTICEBOARD
* FILEORDERSOURCE
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* SCHEDULE
* JOBTEMPLATE

.OUTPUTS
The cmdlet returns an array of referencing objects and referenced objects.

.EXAMPLE
$dependencies = Get-JS7InventoryDependencies -Name myWorkflow -Type WORKFLOW

Returns dependencies of the indicated workflow from the JOC Cockpit inventory.

.EXAMPLE
$configuration = New-Object PSObject
Add-Member -Membertype NoteProperty -Name 'name' -value 'MyWorkflow' -InputObject $configuration
Add-Member -Membertype NoteProperty -Name 'type' -value 'WORKFLOW' -InputObject $configuration
$configurations = @( $configuration )
$dependencies = Get-JS7InventoryDependencies -Configuration $configurations

Creates an array of configuration objects that hold the 'name' and 'type' property.
The object is passed to the cmdlet that will return dependencies for the indicated scheduling objects.

.LINK
about_JS7

#>
[cmdletbinding()]
[OutputType([System.Object[]])]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBRESOURCE','LOCK','NOTICEBOARD','FILEORDERSOURCE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','JOBTEMPLATE',IgnoreCase = $False)]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [PSObject[]] $Configuration,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('DEPLOY','RELEASE','REVOKE','RECALL','REMOVE','EXPORT','GIT',IgnoreCase = $False)]
    [string] $OperationType = 'DEPLOY',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReferencing,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReferences
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$Name -and !$Configuration )
        {
            throw "$($MyInvocation.MyCommand.Name): One of -Name or -Configuration arguments must be specified"
        }

        if ( $Name -and $Configuration )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of -Name or -Configuration arguments can be specified"
        }

        $returnObjects = @()
        $resultObjects = @()
        $configurations = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Name=$Name, Type=$Type"

        if ( $Configuration )
        {
            $configurations += $Configuration
        } else {
            $objConfiguration = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'name' -value $Name -InputObject $objConfiguration
            Add-Member -Membertype NoteProperty -Name 'type' -value $Type -InputObject $objConfiguration
            $configurations += $objConfiguration
        }
    }

    End
    {
        $body = New-Object PSObject

        if ( $OperationType )
        {
            Add-Member -Membertype NoteProperty -Name 'operationType' -value $OperationType -InputObject $body
        }

        if ( $configurations.count )
        {
            Add-Member -Membertype NoteProperty -Name 'configurations' -value $configurations -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/dependencies' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnObjects = ( $response.Content | ConvertFrom-JSON ).dependencies.requestedItems
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        foreach( $returnObject in $returnObjects )
        {
            if ( $Folder )
            {
                if ( !$returnObject.configuration.path.startsWith("$($Folder)/") )
                {
                    continue
                }
            }

            if ( $NoReferencing -eq $False )
            {
                foreach( $referencedBy in $returnObject.referencedBy )
                {
                    if ( $referencedBy -notin $resultObjects )
                    {
                        if ( $Folder )
                        {
                            if ( $referencedBy.path.startsWith("$($Folder)/") )
                            {
                                $resultObjects += $referencedBy
                            }
                        } else {
                            $resultObjects += $referencedBy
                        }
                    }
                }
            }

            if ( $NoReferences -eq $False )
            {
                foreach( $reference in $returnObject.references )
                {
                    if ( $reference -notin $resultObjects )
                    {
                        if ( $Folder )
                        {
                            if ( $reference.path.startsWith("$($Folder)/") )
                            {
                                $resultObjects += $reference
                            }
                        } else {
                            $resultObjects += $reference
                        }
                    }
                }
            }
        }

        $resultObjects

        if ( $resultObjects.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($resultObjects.count) objects found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no dependencies found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
