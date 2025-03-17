function Get-JS7IAMService
{
<#
.SYNOPSIS
Returns one or more JOC Cockpit Identity Services

.DESCRIPTION
This cmdlet returns one or more JOC Cockpit Identity Services.

The following REST Web Service API resources are used:

* /iam/identityservices

.PARAMETER Service
Specifies the unique name of the Identity Service.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns an array of Identity Services.

.EXAMPLE
$services = Get-JS7IAMService

Returns the collection of JOC Cockpit Identity Services.

.EXAMPLE
$service = Get-JS7IAMService -Service 'JOC'

Returns the indicated "JOC" Identity Service.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service
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

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/iam/identityservices' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json ).identityServiceItems

            # if ( !$requestResult )
            # {
            #     throw ( $response | Format-List -Force | Out-String )
            # }

            $requestResult
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($requestResult.count) Identity Services returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
