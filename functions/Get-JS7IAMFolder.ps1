function Get-JS7IAMFolder
{
<#
.SYNOPSIS
Returns folders for a role in a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet returns folders for a role in a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/folders

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Role
Specifies the unique name of a role that is available from the Identity Service.

.PARAMETER ControllerId
Optionally specifies the unique identifier of a Controller should folders for this Controller be returned.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns an array of folders.

.EXAMPLE
$folders = Get-JS7IAMFolder -Service 'JOC' -RoleName 'application_manager'

Returns the folders of the indicated JOC Cockpit Identity Service and role.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service,
    [Alias('RoleName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Role,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'identityServiceName' -value $Service -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'roleName' -value $Role -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/iam/folders' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $requestResult.folders
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): folders returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
