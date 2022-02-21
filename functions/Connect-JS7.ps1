function Connect-JS7
{
<#
.SYNOPSIS
Connects to the JS7 JOC Cockpit Web Service.

.DESCRIPTION
A connection to the JOC Cockpit Web Service is established including support for credentials and use of a proxy.

The cmdlet authenticates a user and returns an access token in case of successful authentication
that is used for subsequent requests to the Web Service.

Caveat:
* This cmdlet calls the Invoke-WebRequest cmdlet that may throw an error 'The response content cannot be parsed because the Internet Explorer engine
is not available, or Internet Explorers first-launch configuration is not complete. Specify the UseBasicParsing parameter and try again.'

* This problem is limited to Windows. The reason for this error is a weird PowerShell dependency on IE assemblies.
* If Internet Explorer is not configured then it prompts the user for configuration when being launched.

* To disable IE's first launch configuration window you can modify the Windows registry
** by running a PowerShell script: Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main' -Name 'DisableFirstRunCustomize' -Value 2
** by using the 'regedit' utility and navigating in the HKLM hive to the above key 'DisableFirstRunCustomize' and assigning the value '2'.
** this operation requires administrative permissions.

.PARAMETER Url
Specifies the URL to access JOC Cockpit. Typically this is the same URL as used with a browser for the JOC Cockpit GUI.

.PARAMETER Credentials
Specifies a credentials object that is used to authenticate the account with the JS7 Web Service.

Credentials can be specified in a script:

* PS C:\> $credential = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'root', ( 'root' | ConvertTo-SecureString -AsPlainText -Force) )

Credentials sets can be managed with Windows built-in tools such as:

* PS C:\> cmdkey /generic:JS7 Web Service /user:root /pass:secret
* The Windows Credential Manager that is available Windows Control Panel.

A previously created credentials set can be retrieved by use of the cmdlet:

* PS C:\> $credentials = Get-JS7SystemCredentials -TargetName "JS7 Web Service"

The credentials object can be assigned the -Credentials parameter.

.PARAMETER UseDefaultCredentials
This parameter currently is not used. It is provided for future versions of JOC Cockpit that support single sign on.

.PARAMETER ProxyUrl
If JOC Cockpit is accessed via a proxy server then the proxy server URL is specified with this parameter.

.PARAMETER ProxyCredentials
If JOC Cockpit is accessed via a proxy server that requires authentication then the credential set
for the proxy server can be specified with this parameter.

.PARAMETER ProxyUseDefaultCredentials
This parameter currently is not used. It is provided for future versions of JOC Cockpit that support single sign on.

.PARAMETER Id
Specifies the ID of a JS7 Controller that is registered with JOC Cockpit.
If no ID is specified then the first JS7 Controller registered with JOC Cockpit will be used.

.PARAMETER AskForCredentials
Specifies that the user is prompted for the account and password that are used for authentication with JS7.

.PARAMETER Base
The Base is used as a prefix to the Path for web service URLs and is configured with the web server
that hosts the JS7 Web Service.

This value is fixed and should not be modified for most use cases.

Default: /joc/api

.PARAMETER Timeout
Specifies the timeout to wait for the JS7 REST Web Service response.

.PARAMETER SSLProtocol
This parameter can be used to specify the TLS protocol version that should be used. The protocol version is agreed
on between the PowerShell client and the JOC Cockpit web server. Both client and server have to agree on a common
protocol version.

* -SSLProtocol 'Tls'
** use any TLS protocol version available
* -SSLProtocol 'Tls12'
** use TLS protocol version 1.2 only
* -SSLProtocol 'Tls11,Tls12'
** use TLS protocol version 1.1 or 1.2 only

.PARAMETER Certificate
This parameter can be used for client authentication if JOC Cockpit is configured for mutual authentication with HTTPS (SSL).
If JOC Cockpit is configured to accept one-factor authentication then the certificate specified with this parameter replaces
the password for login. If JOC Cockpit requires two-factor authentication then a certificate is required
in addition to specifying a password for login.

Consider that this parameter expects a certificate with the data type [System.Security.Cryptography.X509Certificates.X509Certificate2].
This parameter can be used for Windows only. For other operating systems use the -KeyStorePath parameter.

Use of this parameter requires that the certificate object includes the private key and the certificate chain, i.e. the certificate
and any intermediate/root certificates required for validation of the certificate.

This parameter cannot be used with the -CertificateThumbprint parameter or -KeyStorePath parameter.

.PARAMETER CertificateThumbprint
This parameter can be used for client authentication if JOC Cockpit is configured for mutual authentication with HTTPS (SSL).
If JOC Cockpit is configured to accept one-factor authentication then the certificate identified with this parameter replaces
the password for login. If JOC Cockpit requires two-factor authentication then a certificate is required
in addition to specifying a password for login.

This parameter can be used for Windows only. For other operating sysems use the -KeyStorePath parameter.

Use of this parameter requires a certificate store to be in place that holds the private key and certificate chain, i.e. the same certificate
and any intermediate/root certificates required for validation of the certificate. Consider this parameter a reference
to a certificate entry in your Windows certificate store that includes the private key and certificate chain.

This parameter cannot be used with the -Certificate parameter or -KeyStorePath parameter.

.PARAMETER KeyStorePath
This parameter can be used for client authentication if JOC Cockpit is configured for mutual authentication with HTTPS (SSL).
If JOC Cockpit is configured to accept one-factor authentication then the certificate from the keystore specified with this parameter replaces
the password for login. If JOC Cockpit requires two-factor authentication then a certificate is required
in addition to specifying a password for login.

This parameter expects the path to a keystore file, preferably a PKCS12 keystore, that holds the private key and certificate chain, i.e. the certificate
and any intermediate/root certificates required for validation of the certificate. Certificates of type X509 are supported.

The cmdlet adds the private key, certificate and any intermediate/root certificates from the keystore to the certificate store
used by the current account. This parameter can be used for Windows and Unix operating systems.

This parameter cannot be used with the -Certificate parameter or -CertificateThumbprint parameter.

.PARAMETER KeyStoreCredentials
Specifies the credentials for access to a keystore that is indicated with the -KeyStorePath parameter.

A credentials object can be created in a number of ways, e.g.:

$keyStoreCredentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'keystore', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force) )

The first argument 'keystore' is arbitrary, the second argument 'jobscheduler' specifies the password to the keystore.

.PARAMETER RootCertificatePath
Specifies the location of a file that holds the root certificate that was used when signing the JOC Cockpit
SSL certificate.

* For Windows environments the root certificate by default is looked up in the Windows Certificate Store, however,
  this parameter can be used to apply a root certificate from a location in the file system.
* For Linux environments a path is specified to the root certificate file, e.g. *.pem, *.crt file, or to a truststore, e.g. *.jks, *.p12 file.

.PARAMETER RootCertificateCredentials
Specifies the credentials for access to a truststore that holds the root certificate.

A credentials object can be created in a number of ways, e.g.:

$trustStoreCredentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'truststore', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force) )

The first argument 'truststore' is arbitrary, the second argument 'jobscheduler' specifies the password to the truststore.

.PARAMETER SkipCertificateCheck
Specifies that the JOC Cockpit SSL certificate will not be checked, i.e. the identify of the JOC Cockpit instance is not verified.

Use of this parameter is strongly discouraged with secure environments as it trusts a JOC Cockpit SSL certificate without verification.

.PARAMETER ControllerDetails
Returns details about each Controller such as host, port, active role etc.
The details are provided with the "ControllerInstances" data structure in the response.

.EXAMPLE
Connect-JS7 -Url http://localhost:4446 -AskForCredentials

Connects to the JS7 Web Service at the indicated address and asks the user interactively for credentials.

.EXAMPLE
Connect-JS7 -Url https://js7-joc-promary:4443 -AskForCredentials -RootCertificatePath /home/sos/root-ca.crt

Connects to the JS7 Web Service with a secure HTTPS connection at the indicated address and asks the user interactively for credentials.
In order to verfy the JOC Cockpit server certificate the corresponding root certificate is specified that was used when signing the server certificate.

.EXAMPLE
$credentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'root', ( 'root' | ConvertTo-SecureString -AsPlainText -Force) )
Connect-JS7 -Url http://localhost:4446 -Credentials $credentials -Id jobscheduler

A variable $credential is created that holds the credentials for the default root account of JOC Cockpit.
When calling the cmdlet the URL is specified, the Controller ID that was used during installationn and the credential object.

.EXAMPLE
cmdkey /generic:JS7 Web Service /user:root /pass:root
$credentials = Get-JS7SystemCredentials -TargetName "JS7 Web Service"
Connect-JS7 -Url http://localhost:4446 -Credentials $credentials

Prior to use with PowerShell with some external command ("cmdkey") a credential set is generated for the current user.
The credentials are retrieved by use of the Get-JS7SystemCredentials cmdlet and are forwarded to the Connect-JS7 cmdlet.

.EXAMPLE
$trustStoreCredentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'truststore', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force) )
#
$keyStoreCredentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'keystore', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force) )
#
Connect-JS7 -Url https://js7-joc-primary:4443 -Id jobscheduler -RootCertificatePath /home/sos/https-truststore.p12 -RootCertificateCredentials $trustStoreCredentials -KeyStorePath /home/sos/https-keystore.p12 -KeyStorePassword $keyStoreCredentials

This example assumes a secure HTTPS connection to JOC Cockpit with mutual authentication:
* The -RootCertificatePath is specified that holds the root certificate that was used when signing the JOC Cockpit SSL server certificate.
* The -KeyStorePath is specified that hold the private key and certificate for mutual authentication with JOC Cockpit.
* A variable $trustStoreCredentials is created that holds the password for access to the the truststore with the root certificate.
* A variable $keyStoreCredentials is created that holds the credentials for access to they keystore for mutual authentication.

.OUTPUTS
The cmdlet returns an object with access information including the access token for the JS7 Web Service.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $Credentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Id,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $AskForCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $UseDefaultCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $ProxyUrl,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $ProxyCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ProxyUseDefaultCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Base = '/joc/api',
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [int] $Timeout = 30,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $SSLProtocol,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $CertificateThumbprint,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $KeyStorePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $KeyStoreCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $RootCertificatePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $RootCertificateCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $SkipCertificateCheck,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ControllerDetails
)
    Begin
    {
        $stopWatch = Start-JS7StopWatch

        if ( ($Certificate -and $KeyStorePath) -or ( $Certificate -and $CertificateThumbprint) -or ($KeyStorePath -and $CertificateThumbprint) )
        {
             throw "$($MyInvocation.MyCommand.Name): only one of the parameters -Certificate, -CertificateThumbprint or -KeyStorePath can be used"
        }
    }

    Process
    {
        if ( !$jsWebService )
        {
            $script:jsWebService = New-JS7WebServiceObject
        }

        if ( $Url )
        {
            # is protocol provided? e.g. http://localhost:4446
            if ( !$Url.OriginalString.startsWith('http://') -and !$Url.OriginalString.startsWith('https://') )
            {
                $Url = 'http://' + $Url.OriginalString
            }

            # is valid hostname specified?
            if ( [System.Uri]::CheckHostName( $Url.DnsSafeHost ).equals( [System.UriHostNameType]::Unknown ) )
            {
                throw "$($MyInvocation.MyCommand.Name): no valid hostname specified, check use of -Url parameter, e.g. -Url http://localhost:4446: $($Url.OriginalString)"
            }

            $script:jsWebService.Url = $Url
        }

        if ( $ProxyUrl )
        {
            # is protocol provided? e.g. http://localhost:3128
            if ( !$ProxyUrl.OriginalString.startsWith('http://') -and !$ProxyUrl.OriginalString.startsWith('https://') )
            {
                $ProxyUrl = 'http://' + $ProxyUrl.OriginalString
            }

            # is valid hostname specified?
            if ( [System.Uri]::CheckHostName( $ProxyUrl.DnsSafeHost ).equals( [System.UriHostNameType]::Unknown ) )
            {
                throw "$($MyInvocation.MyCommand.Name): no valid hostname specified, check use of -ProxyUrl parameter, e.g. -ProxyUrl http://localhost:3128: $($Url.OriginalString)"
            }

            $script:jsWebService.ProxyUrl = $ProxyUrl
        }

        if ( $Id )
        {
            $script:jsWebService.ControllerId = $Id
        }

        if ( $Base )
        {
            $script:jsWebService.Base = $Base
        }

        if ( $AskForCredentials )
        {
            Write-Output '* ***************************************************** *'
            Write-Output '* JS7 Web Service credentials                           *'
            Write-Output '* enter account and password for authentication         *'
            Write-Output '* ***************************************************** *'
            $account = Read-Host 'Enter account for JS7 Web Service '

            if ( $account )
            {
                $password = Read-Host 'Enter password for JS7 Web Service: ' -AsSecureString
                $Credentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList $account, $password )
            }
        }

        if ( $Credentials )
        {
            $script:jsWebServiceOptionWebRequestUseDefaultCredentials = $false
            $script:jsWebServiceCredential = $Credentials
        } elseif ( $script:jsWebService ) {
            $Credentials = $script:jsWebServiceCredential
        }

        if ( $ProxyCredentials )
        {
            $script:jsWebServiceOptionWebRequestProxyUseDefaultCredentials = $false
            $script:jsWebServiceProxyCredential = $ProxyCredentials
        } elseif ( $script:jsWebServiceProxyCredential ) {
            $ProxyCredentials = $script:jsWebServiceProxyCredential
        }

        if ( $Url.UserInfo )
        {
            $authenticationUrl = $Url.scheme + '://' + $Url.UserInfo + '@' + $Url.Authority + $Base + '/authentication/login'
        } else {
            $authenticationUrl = $Url.scheme + '://' + $Url.Authority + $Base + '/authentication/login'
        }

        if ( $CertificateThumbprint )
        {
            $storeName = [System.Security.Cryptography.X509Certificates.StoreName]
            $storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]
            $openFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]
            $store = [System.Security.Cryptography.X509Certificates.X509Store]::new( $storeName::My, $storeLocation::CurrentUser )

            $store.Open( $openFlags::ReadOnly )
            $certCollection = $store.Certificates.Find( [System.Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint, $CertificateThumbprint, $false )

            if ( $certCollection.count -eq 0 )
            {
                throw "$($MyInvocation.MyCommand.Name): could not find certificate for thumbprint: $CertificateThumbprint"
            }

            if ( $certCollection.count -gt 1 )
            {
                throw "$($MyInvocation.MyCommand.Name): more than one certificate found for thumbprint: $CertificateThumbprint"
            }

            $Certificate = $certCollection[0]
            $store.Close()
        }

        if ( $KeyStorePath )
        {
            $storeName = [System.Security.Cryptography.X509Certificates.StoreName]
            $storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]
            $openFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]
            $store = [System.Security.Cryptography.X509Certificates.X509Store]::new( $storeName::My, $storeLocation::CurrentUser )

            $certPath = ( Resolve-Path $KeyStorePath ).Path

            if ( $KeyStoreCredentials )
            {
                $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2( $certPath, $KeyStoreCredentials.Password )
            } else {
                $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2( $certPath )
            }

            $store.Open( $openFlags::ReadWrite )
            $store.Add( $Certificate )
            $store.Close()
        }

        if ( $RootCertificatePath )
        {
            # add root certificate to truststore
            #     see https://github.com/PowerShell/PowerShell/issues/1865
            #     see https://github.com/dotnet/corefx/blob/Controller/Documentation/architecture/cross-platform-cryptography.md
            $storeName = [System.Security.Cryptography.X509Certificates.StoreName]
            $storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]
            $openFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]
            $store = [System.Security.Cryptography.X509Certificates.X509Store]::new( $storeName::Root, $storeLocation::CurrentUser )

            $certPath = ( Resolve-Path $RootCertificatePath ).Path

            if ( $RootCertificateCredentials )
            {
                $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2( $certPath, $RootCertificateCredentials.Password )
            } else {
                $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2( $certPath )
            }

            $store.Open( $openFlags::ReadWrite )
            $store.Add( $cert )
            $store.Close()
        }

        $requestParams = @{}
        $requestParams.Add( 'Verbose', $false )
        $requestParams.Add( 'Uri', $authenticationUrl )
        $requestParams.Add( 'Headers', @{ 'Accept' = 'application/json'; 'Content-Type' = 'application/json' } )
        $requestParams.Add( 'ContentType', 'application/json' )
        $requestParams.Add( 'Method', 'POST' )

        if ( isPowerShellVersion 6 )
        {
            $requestParams.Add( 'AllowUnencryptedAuthentication', $true )
        }

        if ( isPowerShellVersion 7 )
        {
            $requestParams.Add( 'SkipHttpErrorCheck', $true )
        }

        if ( $UseDefaultCredentials )
        {
            # Windows only
            $requestParams.Add( 'UseDefaultCredentials', $true )
        } else {
            if ( !$Credentials -and $Certificate )
            {
                $cn = $Certificate.Subject.split(',') | Where-Object -FilterScript { $_ -match "CN\s*=" }
                $parts = $cn.split( '=' )
                if ( $parts.count -gt 1 )
                {
                    $Credentials = New-Object -Typename System.Management.Automation.PSCredential( $parts[1].Trim(), (New-Object System.Security.SecureString) )
                } else {
                    throw "no credentials specified and no CN identified from specified certificate, use -Credentials and -Certificate parameter"
                }
            }

            if ( !$Credentials -and $Url.UserInfo ) {
                $parts = $Url.UserInfo.split( ':' )
                if ( $parts.count -gt 1 ) {
                    $securePassword = New-Object Security.SecureString
                    $parts[1].ToCharArray() | ForEach-Object { $securePassword.AppendChar($_) }
                    $Credentials = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $parts[0], $securePassword
                }
            }

            if ( $Credentials ) {
                if ( isPowerShellVersion 6 )
                {
                    $requestParams.Add( 'Authentication', 'Basic' )
                } else {
                    $basicAuthentication = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes( $Credentials.GetNetworkCredential().UserName + ':' + $Credentials.GetNetworkCredential().Password ))
                    $requestParams['Headers'].Add( 'Authorization', "Basic $($basicAuthentication)" )
                }

                $requestParams.Add( 'Credential', $Credentials )
                $script:jsWebServiceOptionWebRequestUseDefaultCredentials = $false
                $script:jsWebServiceCredential = $Credentials
            } else {
               throw "no credentials and no certificate specified, use -Credentials or -Certificate parameter"
            }
        }

        if ( $ProxyUrl )
        {
            $requestParams.Add( 'Proxy', $ProxyUrl )
            $script:jsWebService.ProxyUrl = $ProxyUrl
        }

        if ( $ProxyUseDefaultCredentials )
        {
            # Windows only
            $requestParams.Add( 'ProxyUseDefaultCredentials', $true )
        } elseif ( $ProxyCredentials ) {
            $requestParams.Add( 'ProxyCredential', $ProxyCredentials )
        }

        if ( $Timeout )
        {
            $requestParams.Add( 'TimeoutSec', $Timeout )
            $script:jsWebService.Timeout = $Timeout
        }

        if ( $SkipCertificateCheck )
        {
            $requestParams.Add( 'SkipCertificateCheck', $true )
            $script:jsWebService.SkipCertificateCheck = $true
        }

        if ( $SSLProtocol )
        {
            # $requestParams.Add( 'SSLProtocol', 'Tls' )
            # $requestParams.Add( 'SSLProtocol', 'Tls12' )
            # $requestParams.Add( 'SSLProtocol', 'Tls,Tls11,Tls12' )
            $requestParams.Add( 'SSLProtocol', $SSLProtocol )
            $script:jsWebService.SSLProtcol = $SSLProtocol
        }

        if ( $Certificate )
        {
            # Client Authentication Certificate
            $requestParams.Add( 'Certificate', $Certificate )
            $script:jsWebService.Certificate = $Certificate
        }

        try {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): sending request to JS7 Web Service $($authenticationUrl)"
            Write-Debug ".... Invoke-WebRequest Uri: $($requestParams.Uri)"

            $requestParams.Keys | ForEach-Object {
                if ( $_ -eq 'Headers' )
                {
                    $item = $_
                    $requestParams.Item($_).Keys | ForEach-Object {
                        Write-Debug "...... Headers $_ : $($requestParams.Item($item).Item($_))"
                    }
                } else {
                    Write-Debug "...... $_  $($requestParams.Item($_))"
                }
            }

            $response = Invoke-WebRequest @requestParams

            Write-Debug ".... Invoke-WebRequest response:`n$response"

            if ( $response -and $response.StatusCode -eq 200 -and $response.Content )
            {
                $content = $response.Content | ConvertFrom-JSON
                $script:jsWebService.AccessToken = $content.AccessToken
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): access token: $($content.accessToken)"
            } else {
                $message = $response | Format-List -Force | Out-String
                throw $message
            }


            if ( $Id )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $Id -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/controller/switch' -Body $requestBody

                Write-Debug ".... Invoke-WebRequest response:`n$response"

                if ( $response.StatusCode -eq 200 )
                {
                    $script:jsWebService.ControllerId = $Id
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): sending request to JS7 Web Service /controller/ids"
                Write-Debug ".... Invoke-WebRequest Uri: /controller/ids"

                $body = New-Object PSObject
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/controller/ids' -Body $requestBody

                Write-Debug ".... Invoke-WebRequest response:`n$response"

                if ( $response.StatusCode -eq 200 )
                {
                    $script:jsWebService.ControllerId = ( $response.Content | ConvertFrom-JSON ).selected
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }


            if ( $ControllerDetails )
            {
                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $Id -InputObject $body

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): sending request to JS7 Web Service /controllers"
                Write-Debug ".... Invoke-WebRequest Uri: /controllers"

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/controllers' -Body $requestBody

                Write-Debug ".... Invoke-WebRequest response:`n$response"

                if ( $response.StatusCode -eq 200 )
                {
                    $returnControllerItems = ( $response.Content | ConvertFrom-JSON ).Controllers
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                if ( $returnControllerItems )
                {
                    $script:jsWebService.ControllerInstances = $returnControllerItems
                }
            }

            $script:jsWebService
        } catch {
            $message = $_.Exception | Format-List -Force | Out-String
            throw $message
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
