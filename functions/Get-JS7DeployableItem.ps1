function Get-JS7DeployableItem
{
<#
.SYNOPSIS
Returns deployable scheduling objects such as workflows from the JOC Cockpit inventory

.DESCRIPTION
This cmdlet returns deployable scheduling objects from the JOC Cockpit inventory.

The following REST Web Service API resources are used:

* /inventory/deployable
* /inventory/deployables

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, e.g. a workflow path.

.PARAMETER Type
Specifies the object type which is one of:

* WORKFLOW
* FILEORDERSOURCE
* JOBRESOURCE
* NOTICEBOARD
* LOCK

.PARAMETER Folder
Optionally specifies the folder for which included inventory objects should be returned.
This parameter is used alternatively to the -Path parameter that specifies to return any deployable inventory object from a folder.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up. By default no sub-folders will be considered.

.PARAMETER Valid
Limits the scope to valid schedudling objects only.

.PARAMETER NoDraft
Specifies that no draft objects should be returned. This boils down to the fact that only previously deployed objects will be returned.
Possible use cases include to deploy to a different Controller or to redeploy to the same Controller.

.PARAMETER NoDeployed
Specifies that no previously deployed objects should be returned. This is usefule to prevent redeployment of objects.

.INPUTS
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns deployable objects from the JOC Cockpit inventory.

.EXAMPLE
Get-JS7DeployableItem -Path /TestCases/sampleWorkflow_001 -Type 'WORKFLOW'

Returns the specified workflow from the indicated path.

.EXAMPLE
Get-JS7DeployableItem -Folder /TestRuns -Recursive

Returns deployable objects such as workflows from the specified folder recursively.

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
    [switch] $Valid,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDraft,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDeployed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Latest
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $deployableTypes = @('WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK')
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
                if ( $deployableTypes -notcontains $typeItem )
                {
                    throw "$($MyInvocation.MyCommand.Name): value of -Type parameter not allowed ($($deployableTypes)): $typeItem"
                }
            }
        }

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

            $deployableObject
        } else {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'withoutDrafts' -value ($NoDraft -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'withoutDeployed' -value ($NoDeployed -eq $True) -InputObject $body
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
                $deployableItems.folders.deployables
                $returnItemsCount = ($deployableItems.folders.deployables).count
            } else {
                $deployableItems.deployables
                $returnItemsCount = ($deployableItems.deployables).count
            }
        }
    }

    End
    {
        if ( $returnItemsCount )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $returnObjectItems items found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
