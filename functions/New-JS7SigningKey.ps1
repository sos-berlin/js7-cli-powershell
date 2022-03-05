function New-JS7SigningKey
{
<#
.SYNOPSIS
Creates a new key pair for the current accounts

.DESCRIPTION
Creates a key pair of private key and public key/certificate of the current account.

JS7 supports the following key types: PGP, RSA and ECDSA.

* PGP keys use a private key and a public key.
* RSA and ECDSA use a private key and a signed certificate. The certificate can be self-signed or CA-signed. The public key is not used.

Depending on the security level that JOC Cockpit is operated for one of the following items is returned:

* public key/certificate if security level HIGH is used.
* public key/certificate and private key if security level LOW or MEDIUM are used.

The following REST Web Service API resources are used:

* /profile/key/generate

.PARAMETER KeyAlgorithm
JS7 supports the following key algorithms: PGP, RSA and ECDSA.

.PARAMETER ValidUntil
Specifies the limit of validit of the newly created key. The date is specified for the UTC timezone.


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
$key = New-JS7SigningKey -KeyAlgorithm PGP

A PGP key pair of private key and public key is created.

.EXAMPLE
$key = New-JS7SigningKey -KeyAlgorithm ECDSA

An ECDSA private key is created. Consider that this key requires a self-signed or CA-signed certificate that can be
added by use of the Add-JS7SigningKey cmdlet.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('PGP','RSA','ECDSA')]
    [string] $KeyAlgorithm,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $ValidUntil,
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
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter KeyAlgorith=$KeyAlgorithm, ValidUntil=$ValidUntil"

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'keyAlgorithm' -value $KeyAlgorithm -InputObject $body

        if ( $ValidUntil )
        {
            Add-Member -Membertype NoteProperty -Name 'validUntil' -value (Get-Date (Get-Date $ValidUntil).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
        }

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

        if ( $PSCmdlet.ShouldProcess( 'key', '/profile/key/generate' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/profile/key/generate' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $returnKey = ( $response.Content | ConvertFrom-Json )
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            $returnKey
        }

        if ( $returnKey )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): key created"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no key created"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
