function Get-JS7Lock
{
<#
.SYNOPSIS
Returns Locks from the JOC Cockpit inventory

.DESCRIPTION
Locks are returned from JOC Cockpit that have been deployed to the current Controller instances.
Locks can be selected either by the folder of the lock location including sub-folders or by an individual lock path.

Resulting locks can be forwarded to other cmdlets for pipelined bulk operations.

.PARAMETER LockPath
Optionally specifies the path and name of a lock that should be returned.

One of the parameters -Folder or -LockPath has to be specified.

.PARAMETER Folder
Optionally specifies the folder for which locks should be returned.

One of the parameters -Folder or -LockPath has to be specified.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up. By default no sub-folders will be searched for locks.

.OUTPUTS
This cmdlet returns an array of lock objects.

.EXAMPLE
$locks = Get-JS7Lock

Returns all deployed locks.

.EXAMPLE
$locks = Get-JS7Lock -Folder /some_folder -Recursive

Returns all locks that are configured with the specified folder
including any sub-folders.

.EXAMPLE
$locks = Get-JS7Lock -LockPath /test/globals/lock1

Returns the lock "lock1" from the folder "/test/globals".

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $LockPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $lockPaths = @()
        $folders = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, LockPath=$LockPath"

        if ( $Folder -and $Folder -ne '/' )
        {
            if ( !$Folder.StartsWith( '/' ) )
            {
                $Folder = '/' + $Folder
            }

            if ( $Folder.EndsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }

        if ( !$Folder -and !$LockPath )
        {
            throw "$($MyInvocation.MyCommand.Name): no folder and no lock path specified, use -Folder or -LockPath"
        }

        if ( $Folder -eq '/' -and !$LockPath -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $LockPath )
        {
            $lockPaths += $LockPath
        }

        if ( $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder

            if ( $Recursive )
            {
                Add-Member -Membertype NoteProperty -Name 'recursive' -value $True -InputObject $objFolder
            }

            $folders += $objFolder
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $lockPaths )
        {
            Add-Member -Membertype NoteProperty -Name 'lockPaths' -value $lockPaths -InputObject $body
        }

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/locks' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnLocks += ( $response.Content | ConvertFrom-JSON ).locks
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnLocks

        if ( $returnLocks.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnLocks.count) locks found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no locks found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
