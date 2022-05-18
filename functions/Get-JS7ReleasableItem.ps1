function Get-JS7ReleasableItem
{
<#
.SYNOPSIS
Returns releasable scheduling objects such as schedules from the JOC Cockpit inventory

.DESCRIPTION
This cmdlet returns releasable scheduling objects from the JOC Cockpit inventory.
Such objects are not deployed to Controllers and Agents but are used by JOC Cockpit services
for example to automatically create orders for the daily plan.

The following REST Web Service API resources are used:

* /inventory/releasable
* /inventory/releasables

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, e.g. a schedule path.

.PARAMETER Type
Specifies the object type which is one of:

* INCLUDESCRIPT
* SCHEDULE
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR

.PARAMETER Folder
Optionally specifies the folder for which included inventory objects should be returned.
This parameter is used alternatively to the -Path parameter that specifies to return an individual inventory object.

.PARAMETER Recursive
Specifies that all sub-folders should be looked up. By default no sub-folders will be considered.

.PARAMETER Valid
Limits the scope to valid schedudling objects only.

.PARAMETER NoDraft
Specifies that no draft objects should be returned. This boils down to the fact that only previously released objects will be returned.

.PARAMETER NoReleased
Specifies that no previously released objects should be returned.

.INPUTS
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns releasable objects from the JOC Cockpit inventory.

.EXAMPLE
Get-JS7ReleasableItem -Path /TestCases/sampleSchedule001 -Type 'SCHEDULE'

Returns the specified schedule with the indicated path.

.EXAMPLE
Get-JS7ReleasableItem -Folder /TestCases -Recursive

Returns releasable objects from a folder and any sub-folders.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('INCLUDESCRIPT','SCHEDULE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoReleased
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $releasableTypes = @('INCLUDESCRIPT','SCHEDULE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR')
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

        if ( $Type )
        {
            foreach( $typeItem in $Type )
            {
                if ( $releasableTypes -notcontains $typeItem )
                {
                    throw "$($MyInvocation.MyCommand.Name): value of -Type parameter not allowed ($($releasableTypes)): $typeItem"
                }
            }
        }

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

            $releasableObject
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
                $releasableItems.folders.releasables
                $returnItemsCount = ($releasableItems.folders.releasables).count
            } else {
                $releasableItems.releasables
                $returnItemsCount = ($releasableItems.releasables).count
            }
        }
    }

    End
    {
        if ( $returnItemsCount )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $returnItemsCount items returned"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items returned"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
