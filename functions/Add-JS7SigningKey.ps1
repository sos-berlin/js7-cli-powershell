function Add-JS7SigningKey
{
<#
.SYNOPSIS
Adds a key pair for signing of deployable objects such as workflows to the current account

.DESCRIPTION
Adds a key pair of private key and public key/certificate that can be used to sign deployable objects
such as workflows to the current account.

JS7 supports the following key types: PGP, RSA and ECDSA.

* PGP keys use a private key and a public key.
* RSA and ECDSA use a private key and a signed certificate. The certificate can be self-signed or CA-signed. The public key is not used.

Depending on the security level that JOC Cockpit is operated for one of the following items can be added:

* public key/certificate if security level HIGH is used.
* public key/certificate and private key if security level LOW or MEDIUM are used.

.PARAMETER KeyAlgorithm
JS7 supports the following key algorithms: PGP, RSA and ECDSA.

.PARAMETER PrivateKey
A private key of the type specified with the -KeyAlgorithm parameter is specified.

The private key string is expected to include any newline characters required for the key type.

.PARAMETER Publickey
A public key can be specified only when using the PGP key type specified with the -KeyAlgorithm parameter.

The public key string is expected to include any newline characters required for the key type.

.PARAMETER Certificate
A certificate can be specified only when using the RSA, ECDSA key types specified with the -KeyAlgorithm parameter.

The certificate string is expected to include any newline characters required for the key type.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.OUTPUTS
This cmdlet returns an object with public key/certificate and optionally private key items.

.EXAMPLE
Add-JS7SigningKey -KeyAlgorithm RSA -PrivateKey "----BEGIN PGP PRIVATE KEY BLOCK-----\n..." -Certificate "-----BEGIN CERTIFICATE-----\n..."

For RSA and ECDSA key types the certificate and the private key
are added if JOC Cockpit is operated for security level LOW or MEDIUM.

.EXAMPLE
Add-JS7SigningKey -KeyAlgorithm RSA -PrivateKey (Get-Content c:/sos/certs/2.0/sos.private-ec-key.pem -Raw) -Certificate (Get-Content c:/sos/certs/2.0/sos.certificate-ec-key.pem -Raw)

The private key and public key are used from raw file input to preserve any newlines in the key files.

.EXAMPLE
Add-JS7SigningKey -KeyAlgorithm ECDSA -Certificate "-----BEGIN CERTIFICATE-----\n..."

For RSA and ECDSA key types the certificate is added if JOC Cockpit is operated for security level HIGH.

.EXAMPLE
Add-JS7SigningKey -KeyAlgorithm PGP -PrivateKey "-----BEGIN PGP PRIVATE KEY BLOCK-----\n..." -PublicKey "-----BEGIN PGP PUBLIC KEY BLOCK-----\n..."

For PGP key types the public key and the private key are added if JOC Cockpit is operated for security level LOW or MEDIUM.

.EXAMPLE
Add-JS7SigningKey -KeyAlgorithm PGP  -PublicKey "-----BEGIN PGP PUBLIC KEY BLOCK-----\n..."

For PGP key types the public key is added if JOC Cockpit is operated for security level HIGH.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('PGP','RSA','ECDSA')]
    [string] $KeyAlgorithm,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $PrivateKey,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $PublicKey,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Certificate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        $securityLevel = (Get-JS7JOCProperties).securityLevel
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter KeyAlgorith=$KeyAlgorithm"

        if ( $KeyAlgorithm -eq 'RSA' -or $KeyAlgorithm -eq 'ECDSA' )
        {
            if ( $securityLevel -eq 'HIGH' )
            {
                if ( $PrivateKey )
                {
                    throw "$($MyInvocation.MyCommand.Name): private key cannot be added for security level HIGH, use -Certificate parameter"
                }
            } else {
                if ( !$PrivateKey )
                {
                    throw "$($MyInvocation.MyCommand.Name): private key required, use -PrivateKey parameter"
                }
            }

            if ( !$Certificate )
            {
                throw "$($MyInvocation.MyCommand.Name): certificate required for security level HIGH, use -Certificate parameter"
            }
        } else {
            if ( $securityLevel -eq 'HIGH' )
            {
                if ( $PrivateKey )
                {
                    throw "$($MyInvocation.MyCommand.Name): private key cannot be added for security level HIGH, use -PublicKey parameter"
                }
            } else {
                if ( !$PrivateKey )
                {
                    throw "$($MyInvocation.MyCommand.Name): private key required, use -PrivateKey parameter"
                }
            }

            if ( !$PublicKey )
            {
                throw "$($MyInvocation.MyCommand.Name): public key required for security level HIGH, use -PublicKey parameter"
            }
        }


        $keys = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'keyAlgorithm' -value $KeyAlgorithm -InputObject $keys

        if ( $PrivateKey )
        {
            Add-Member -Membertype NoteProperty -Name 'privateKey' -value $PrivateKey -InputObject $keys
        }

        if ( $PublicKey )
        {
            Add-Member -Membertype NoteProperty -Name 'publicKey' -value $PublicKey -InputObject $keys
        }

        if ( $Certificate )
        {
            Add-Member -Membertype NoteProperty -Name 'certificate' -value $Certificate -InputObject $keys
        }

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'keys' -value $keys -InputObject $body

        if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
        {
            $objAuditLog = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

            if ( $AuditTimeSpent )
            {
                Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
            }

            if ( $AuditTicketLink )
            {
                Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
            }

            Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/profile/key/store' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            if ( !($response.Content | ConvertFrom-JSON).ok )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): keys added"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
