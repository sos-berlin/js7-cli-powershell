function Get-JS7JOCLicense
{
<#
.SYNOPSIS
Returns JS7 JOC Cockpit license information

.DESCRIPTION
This cmdlet returns JOC Cockpit license information, for example:

* Open Source License
* Commercial License
** Validity
** License valid from
** License valid to

The following REST Web Service API resources are used:

* /joc/license

.INPUTS
This cmdlet accepts no pipelined input.

.OUTPUTS
This cmdlet returns an object with license information

.EXAMPLE
$license = Get-JS7JOCLicense

Returns JOC Cockpit license information.

.LINK
about_JS7

#>
param
(
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject
        [string] $requestBody = $body | ConvertTo-Json -Depth 100

        $response = Invoke-JS7WebRequest -Path '/joc/license' -Body $requestBody
        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $requestResult

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): license information returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
