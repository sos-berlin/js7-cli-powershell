function Publish-JS7ReleasableItem
{
<#
.SYNOPSIS
Releases scheduling objects such as schedules and calendars

.DESCRIPTION
This cmdlet releases scheduling objects such as schedules and calendars for use with JOC Cockpit.
Such objects are not deployed to a JS7 Controller, instead they are used for example to automatically
create orders for the daily plan from a JOC Cockpit service.

Releasing can include to permanently deleting previously removed objects from the inventory.

The following REST Web Service API resources are used:

* /inventory/releasable
* /inventory/releasables
* /inventory/release

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, e.g. a schedule path.

.PARAMETER Type
Specifies the object type which is one of:

* INCLUDESCRIPT
* SCHEDULE
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* REPORT

.PARAMETER Folder
Optionally specifies the folder for which included inventory objects should be published.
This parameter is used alternatively to the -Path parameter that specifies to publish an individual inventory object.

.PARAMETER Recursive
Specifies that all sub-folders should be looked up. By default no sub-folders will be considered.

.PARAMETER Delete
Specifies the action to permanently delete previously removed objects.
Without this switch objects are released for use with any JS7 Controller.

.PARAMETER Valid
Limits the scope to valid scheduling objects only.

.PARAMETER NoDraft
Specifies that no draft objects should be released. This boils down to the fact that only previously released objects will be released.

.PARAMETER NoReleased
Specifies that no previously released objects should be released.

.PARAMETER ObjectName
Internal use for pipelining.

.PARAMETER ObjectName
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
This cmdlet accepts pipelined job objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Publish-JS7ReleasableItem -Folder /TestCases -Recursive

Releases any object types from the indicated folder and any sub-folders for use with a JS7 Controller.

.EXAMPLE
Publish-JS7ReleasableItem -Path /TestCases/sampleSchedule001 -Type 'SCHEDULE'

Releases the specified schedule from the indicated path for use with a JS7 Controller.

.EXAMPLE
Publish-JS7ReleasableItem -Path /TestCases/sampleWorkflow -Type 'WORKFLOW' -Delete

Marks for deletion the specified workflow.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('INCLUDESCRIPT','SCHEDULE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','REPORT',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Delete,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReleased,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('INCLUDESCRIPT','SCHEDULE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','REPORT',IgnoreCase = $False)]
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

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $storeObjects = @()
        $deleteObjects = @()
        $releasableTypes = @('INCLUDESCRIPT','SCHEDULE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR')

        if (IsJOCVersion -Major 2 -Minor 7 -Patch 1 )
        {
            $releasableTypes += 'REPORT'
        }
    }

    Process
    {
        While ( $Folder.endsWith('/') -and $Folder -ne '/' )
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

        if ( !$Path -and !$Folder )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the parameters -Path or -Folder has to be used"
        }

        if ( $Type.count )
        {
            for( $i=0; $i -lt $Type.length; $i++ )
            {
                if ( $releasableTypes -notcontains $Type[$i] )
                {
                    throw "$($MyInvocation.MyCommand.Name): value of -Type parameter not allowed ($($releasableTypes)): $typeItem"
                } else {
                    $Type[$i] = $Type[$i].toUpper()
                }
            }
        } else {
            $Type = $releasableTypes
        }

        if ( $Path )
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

            if ( $Delete )
            {
                $deleteObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $releasableObject.valid; 'released' = $releasableObject.released }
            } else {
                $storeObjects += @{ 'path' = $Path; 'type' = $Type[0]; 'valid' = $releasableObject.valid; 'released' = $releasableObject.released }
            }
        } else {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
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

            foreach( $releasableObject in $releasableObjects )
            {
                if ( !$releasableObject.objectType -or $releasableObject.objectType -eq 'FOLDER' )
                {
                    # we cannot release folders
                    continue
                }

                if ( $releasableObject.folder -and !$releasableObject.folder.endsWith( '/' ) )
                {
                    $releasableObject.folder += '/'
                }

                if ( $Delete )
                {
                    $deleteObjects += @{ 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; 'valid' = $releasableObject.valid; 'released' = $releasableObject.released }
                } else {
                    $storeObjects += @{ 'path' = "$($releasableObject.folder)$($releasableObject.objectName)"; 'type' = $releasableObject.objectType; 'valid' = $releasableObject.valid; 'released' = $releasableObject.released }
                }
            }
        }
    }

    End
    {
        if ( $storeObjects.count -or $deleteObjects.count )
        {
            $body = New-Object PSObject

            $objects = @()
            foreach( $object in $storeObjects )
            {
                $storeObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $storeObject
                Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $storeObject
                $objects += $storeObject
            }

            if ( $objects )
            {
                Add-Member -Membertype NoteProperty -Name 'update' -value $objects -InputObject $body
            }


            $objects = @()
            foreach( $object in $deleteObjects )
            {
                $deleteObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $deleteObject
                Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $deleteObject
                $objects += $deleteObject
            }

            if ( $objects )
            {
                Add-Member -Membertype NoteProperty -Name 'delete' -value $objects -InputObject $body
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
            $response = Invoke-JS7WebRequest -Path '/inventory/release' -Body $requestBody

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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($storeObjects.count+$deleteObjects.count) items released"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items released"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
