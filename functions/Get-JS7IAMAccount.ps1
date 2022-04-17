function Get-JS7IAMAccount
{
<#
.SYNOPSIS
Returns accounts from a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet returns accounts from a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/accounts

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Account
Optionally limits the result to the specified user account.

.PARAMETER Disabled
Optionally returns disabled accounts only. By default enabled accounts only are returned.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns an array of accounts.

.EXAMPLE
$accounts = Get-JS7IAMAccount -Service 'JOC'

Returns the accounts from the indicated JOC Cockpit Identity Service.

.EXAMPLE
$account = Get-JS7IAMAccount -Service 'JOC' -Account 'matt'

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
    [string] $Account,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Disabled
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
        Add-Member -Membertype NoteProperty -Name 'disabled' -value ($Disabled -eq $True) -InputObject $body

        if ( $Account )
        {
            Add-Member -Membertype NoteProperty -Name 'accountName' -value $Account -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/iam/accounts' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $requestResult.accountItems )
            {
                $requestResult.accountItems
            } else {
                $requestResult
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): account returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
