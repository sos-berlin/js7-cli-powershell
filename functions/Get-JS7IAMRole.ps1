function Get-JS7IAMRole
{
<#
.SYNOPSIS
Returns a number of roles from a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet returns a number of roles from a JOC Cockpit Identity Service

The following REST Web Service API resources are used:

* /iam/roles

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Role
Specifies the unique name of a role that is available from the Identity Service.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns one or more roles.

.EXAMPLE
$roles = Get-JS7IAMRole -Service 'JOC'

Returns the roles of the indicated Identity Service.

.EXAMPLE
$role = Get-JS7IAMRole -Service 'JOC' -Role 'application_manager'

Returns the given role of the indicated Identity Service.

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
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Role
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

        if ( $Role )
        {
            Add-Member -Membertype NoteProperty -Name 'roleName' -value $Role -InputObject $body
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/role' -Body $requestBody
        } else {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/roles' -Body $requestBody
        }

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $Role )
            {
                $requestResult
            } else {
                $requestResult.roles
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): roles returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
