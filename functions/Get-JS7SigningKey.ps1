function Get-JS7SigningKey
{
<#
.SYNOPSIS
Returns the current accounts's signing key from the user profile

.DESCRIPTION
Return the key pair of private key and public key/certificate of the current account that is used to sign
objects such as workflows for deplyoment.

JS7 supports the following key types: PGP, RSA and ECDSA.

* PGP keys use a private key and a public key.
* RSA and ECDSA use a private key and a signed certificate. The certificate can be self-signed or CA-signed. The public key is not used.

Depending on the security level that JOC Cockpit is operated for one of the following items is returned:

* public key/certificate if security level HIGH is used.
* public key/certificate and private key if security level LOW or MEDIUM are used.

.OUTPUTS
This cmdlet returns an object with public key/certificate and optionally private key items.

.EXAMPLE
$key = Get-JS7SigningKey

For RSA and ECDSA key types the certificate and the private key
is returned if JOC Cockpit is operated for security level LOW or MEDIUM.

.EXAMPLE
$key = Get-JS7SigningKey

For RSA and ECDSA key types the certificate is returned if JOC Cockpit is operated for security level HIGH.

.EXAMPLE
$key = Get-JS7SigningKey

For PGP key types the public key and the private key is returned if JOC Cockpit is operated for security level LOW or MEDIUM.

.EXAMPLE
$key = Get-JS7SigningKey

For PGP key types the public key is returned if JOC Cockpit is operated for security level HIGH.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter"

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/profile/key'
    
        if ( $response.StatusCode -eq 200 )
        {
            $returnKey = ( $response.Content | ConvertFrom-JSON )
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }
    
        $returnKey

        if ( $returnKey )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): key found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no key found"
        }
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session        
    }
}
