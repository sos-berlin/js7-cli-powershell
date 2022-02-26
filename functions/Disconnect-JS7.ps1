function Disconnect-JS7
{
<#
.SYNOPSIS
Disconnects from the JS7 REST Web Service.

.DESCRIPTION
This cmdlet can be used to disconnect from the JS7 REST Web Service.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
)
    Process
    {
        $response = Invoke-JS7WebRequest -Path '/authentication/logout' -Body ""

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON )

            if ( $requestResult.isAuthenticated -ne $false )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $script:jsWebService = New-JS7WebServiceObject
        $script:jsWebServiceCredential = $null
    }
}
