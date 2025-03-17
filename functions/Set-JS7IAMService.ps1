function Set-JS7IAMService
{
<#
.SYNOPSIS
Stores a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet stores a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/identityservice/store

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Type
Specifies the type of the Identity Service which is one of:

* CERTIFICATE: allow access from certificates, manage roles with JOC Cockpit
* FIDO: manage accounts from FIDO, manage roles with JOC Cockpit
* JOC: manage accounts and roles with JOC Cockpit
* KEYCLOAK: manage accounts and roles with Keycloak Server
* KEYCLOAK-JOC: manage accounts with Keycloak Server, mange roles with JOC Cockpit
* LDAP: manage accounts and roles with LDAP Server
* LDAP-JOC: manage accounts with LDAP Server, manage roles with JOC Cockpit
* OIDC: manage accounts and roles with OIDC Server
* OIDC-JOC: manage accounts with OIDC Server, manage roles with JOC Cockpit
* VAULT: manage accounts and roles with Vault Server
* VAULT-JOC: manage accounts with Vault Server, manage roles with JOC Cockpit
* VAULT-JOC-ACTIVE: manage accounts with Vault Server and JOC Cockpit, manage roles with JOC Cockpit

.PARAMETER Ordering
Optionally specifies the position in the list of Identity Services.

.PARAMETER Required
Specifies if the Identity Service is required. For any required Identity Services users have to perform a login.

.PARAMETER Disabled
The Identity Service is disabled, i.e. it is not used for authentication of user accounts.

.PARAMETER SecondFactor
Specifies that the Identity Service is used as a second factor in MFA.

.PARAMETER AuthenticationScheme
* Optionally specifies the authentication scheme which is one of

* SINGLE-FACTOR: Certificate or Password can be used for authentication.
* TWO-FACTOR: Certificate and Password have to be used for authentication.

.PARAMETER SingleFactorCertificate
iF single-factor authentication is used then this switch specifies if certificates are accepted as a single factor.

.PARAMETER SingleFactorPassword
iF single-factor authentication is used then this switch specifies if passwords are accepted as a single factor.

.PARAMETER SecondFactorService
If the -AuzthenticationScheme parameter is used with the TWO-FACTOR value, then the argument
specifies the name of the Identity Service that is used as a second factor.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention,
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This argument is not mandatory, however, JOC Cockpit can be configured
to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns the Identity Service object.

.EXAMPLE
$service = Set-JS7IAMService -Service 'JOC' -Type 'JOC' -SingleFactorPassword

Stores the Identity Service to JOC Cockpit for use with passwords as a single factor.

.EXAMPLE
$service = Set-JS7IAMService -Service 'Certficate' -Type CERTIFICATE -SingleFactorCertificate -SecondFactor

Stores the Identity Service for use with certificates as a second factor in MFA.

.EXAMPLE
$service = Set-JS7IAMService -Service 'Multi-Factor' -Type JOC -AuthenticationScheme 'TWO-FACTOR' -SecondFactorService 'Certificate'

Stores the Identity Service for MFA using a password and a certificate from the 'Certificate' Identity Service.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service,
    [Alias('IdentityServiceType')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('CERTIFICATE','FIDO','JOC','KEYCLOAK','KEYCLOAK-JOC','LDAP','LDAP-JOC','OIDC','OIDC-JOC','VAULT','VAULT-JOC','VAULT-JOC-ACTIVE',IgnoreCase = $False)]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Ordering,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Required,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Disabled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $SecondFactor,
    [Alias('ServiceAuthenticationScheme')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('SINGLE-FACTOR','TWO-FACTOR',IgnoreCase = $False)]
    [string] $AuthenticationScheme = 'SINGLE-FACTOR',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $SingleFactorCertificate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $SingleFactorPassword,
    [Alias('SecondFactorIdentityServiceName')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SecondFactorService,
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

        if ( $AuthenticationScheme -and ( $AuthenticationScheme -ne 'SINGLE-FACTOR' -and $AuthenticationScheme -ne 'TWO-FACTOR' ) )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the authentication schemes 'SINGLE-FACTOR' or 'TWO-FACTOR' has to be used"
        }

        if ( $AuthenticationScheme -eq 'SINGLE-FACTOR' -and !$SingleFactorCertificate -and !$SingleFactorPassword )
        {
            throw "$($MyInvocation.MyCommand.Name): one of the authentication factors -SingleFactorCertificate or -SingleFactorPassword has to be used"
        }

        if ( $AuthenticationScheme -eq 'TWO-FACTOR' -and ( $SingleFactorCertificate -or $SingleFactorPassword ) )
        {
            throw "$($MyInvocation.MyCommand.Name): two-factor authentication cannot be used with a choice of -SingleFactorCertificate and -SingleFactorPassword"
        }

        if ( $AuthenticationScheme -eq 'TWO-FACTOR' -and !$SecondFactorService )
        {
            throw "$($MyInvocation.MyCommand.Name): two-factor authentication requires to specify name of second identity service using -SecondFactorService"
        }
    }

    Process
    {
        $body = New-Object PSObject

        Add-Member -Membertype NoteProperty -Name 'identityServiceName' -value $Service -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'identityServiceType' -value $Type -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'required' -value ($Required -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'disabled' -value ($Disabled -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'secondFactor' -value ($SecondFactor -eq $True) -InputObject $body

        if ( $Ordering )
        {
            Add-Member -Membertype NoteProperty -Name 'ordering' -value $Ordering -InputObject $body
        }

        if ( $AuthenticationScheme )
        {
            Add-Member -Membertype NoteProperty -Name 'serviceAuthenticationScheme' -value $AuthenticationScheme -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'singleFactorCert' -value ($SingleFactorCertificate -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'singleFactorPwd' -value ($SingleFactorPassword -eq $True) -InputObject $body
        }

        if ( $SecondFactorService )
        {
            Add-Member -Membertype NoteProperty -Name 'secondFactorIdentityServiceName' -value $SecondFactorService -InputObject $body
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

        if ( $PSCmdlet.ShouldProcess( 'identity service', '/iam/identityservice/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/identityservice/store' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json )

                # if ( !$requestResult )
                # {
                #     throw ( $response | Format-List -Force | Out-String )
                # }

                $requestResult
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): Identity Service stored"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
