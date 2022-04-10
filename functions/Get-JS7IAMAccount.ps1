function Get-JS7IAMAccount
{
<#
.SYNOPSIS
Returns accounts of a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet returns accounts in a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/accounts

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Account
Optionally limits the result to the specified user account.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns an array of accounts.

.EXAMPLE
$accounts = Get-JS7IAMAccount -Service JOC

Returns the accounts from the indicated JOC Cockpit Identity Service.

.EXAMPLE
$accounts = Get-JS7IAMAccount -Service JOC -Account 'matt'

Returns the given account from the indicated JOC Cockpit Identity Service.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service,
    [Alias('AccountName')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Account
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

        if ( $Account )
        {
            Add-Member -Membertype NoteProperty -Name 'accountName' -value $Account -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/iam/accounts' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json ).accountItems

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            $requestResult
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($requestResult.count) accounts returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
