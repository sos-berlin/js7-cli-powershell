function Get-JS7GitCredentials
{
<#
.SYNOPSIS
Returns Git credentials for the current user account

.DESCRIPTION
This cmdlet returns Git credentials for the current user account. The functionality considers the security level:

* LOW: credentials are added to the default account, typically the root account
* MEDIUM: credentials are added per user account
* HIGH: no credentials are added

Credentials are added for one of the following authentication methods:

* Password: A larger number of Git servers is configured to deny password authentication.
* Access Token: Such tokens are created and stored with the Git server.
* Private Key: Makes use of SSH authentication with a private key file

The following REST Web Service API resources are used:

* /inventory/repository/git/credentials

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
$creds = Get-JS7GitCredentials

Returns credentials for access to a Git server for the current account.

.LINK
about_JS7

#>
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/repository/git/credentials' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $requestResult
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): credentials returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
