function Get-JS7InventoryChange
{
<#
.SYNOPSIS
Returns Changes from the JOC Cockpit inventory

.DESCRIPTION
Changes are selected from the JOC Cockpit inventory

* by the name of a change,
* by the status of a change,
* by the owner of a change,

Without specifying a change the list of all changes will be returned.

Resulting changes can be forwarded to other cmdlets for pipelined bulk operations.

The following REST Web Service API resources are used:

* /inventory/changes

.PARAMETER Name
Optionally specifies the name of a change that should be returned.

.PARAMETER State
Optionally specifies the state of changes that should be returned.

* OPEN
* CLOSED

.PARAMETER Owner
Optionally specifies the owner account of changes that should be returned.

.PARAMETER PublishedBy
Optionally specifies the account that most recently published changes that should be returned.

.PARAMETER Detailed
Specifies that in addition to changes the related inventory objects will be returned.

.OUTPUTS
This cmdlet returns an array of change objects.

.EXAMPLE
$change = Get-JS7Change -Name "CH-TestRepo-01"

Returns the change that is stored with the name "CH-TestRepo-01".

.EXAMPLE
$changes = Get-JS7Change

Returns all changes available with the JOC Cockpit inventory.

.EXAMPLE
$changes = Get-JS7Change -State OPEN

Returns all open changes.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Name,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('OPEN','CLOSED',IgnoreCase = $False)]
    [string[]] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Owner,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $PublishedBy,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Detailed
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $returnChanges = @()
        $names = @()
        $states = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Name=$Name, State=$State"

        if ( $Name )
        {
            $names += $Name
        }

        if ( $State )
        {
            $states += $State
        }
    }

    End
    {
        $body = New-Object PSObject

        if ( $names.count )
        {
            Add-Member -Membertype NoteProperty -Name 'names' -value $names -InputObject $body
        }

        if ( $states.count )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        if ( $Owner )
        {
            Add-Member -Membertype NoteProperty -Name 'owner' -value $Owner -InputObject $body
        }

        if ( $PublishedBy )
        {
            Add-Member -Membertype NoteProperty -Name 'publishedBy' -value $Owner -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'details' -value ($Detailed -eq $True) -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/changes' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnChanges = ( $response.Content | ConvertFrom-JSON ).changes
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        foreach( $returnChange in $returnChanges )
        {
            foreach( $configuration in $returnChange.configurations )
            {
                Add-Member -Membertype NoteProperty -Name 'type' -value $configuration.objectType -InputObject $configuration
            }
        }

        $returnChanges

        if ( $returnChanges.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnChanges.count) changes found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no changes found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
