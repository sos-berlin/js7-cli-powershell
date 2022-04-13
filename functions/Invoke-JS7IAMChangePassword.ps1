function Invoke-JS7IAMChangePassword
{
<#
.SYNOPSIS
Modifies the password for one or more accounts in a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet modifies the password of one or more accounts in a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/account/changepassword

.PARAMETER Service
Specifies the unique name of the Identity Service that the accounts is managed with.

.PARAMETER Account
Specifies the unique names of one or more accounts for which the password is reset.

.PARAMETER Password
Specifies the account's password.

The password has to be specified as a secure string, for example:

$oldPassword = ConvertTo-SecureString 'secret' -AsPlainText -Force

.PARAMETER NewPassword
Specifies the account's new password.

The password has to be specified as a secure string, for example:

$newPassword = ConvertTo-SecureString 'very-secret' -AsPlainText -Force

.PARAMETER ForcePasswordChange
Specifies that the account has to change the password with the next login.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
$oldPassword = ConvertTo-SecureString 'secret' -AsPlainText -Force
$newPassword = ConvertTo-SecureString 'very-secret' -AsPlainText -Force
Invoke-JS7IAMChangePassword -Service JOC -Account 'user1' -Password $oldPassword -NewPassword $newPassword

Sets the account's password.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service,
    [Alias('AccountName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Account,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [SecureString] $Password,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [SecureString] $NewPassword,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForcePasswordChange,
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
    }

    Process
    {
        $body = New-Object PSObject

        Add-Member -Membertype NoteProperty -Name 'identityServiceName' -value $Service -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'accountName' -value $Account -InputObject $body

        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode( $Password )
        Add-Member -Membertype NoteProperty -Name 'oldPassword' -value ( [System.Runtime.InteropServices.Marshal]::PtrToStringUni( $ptr ) ) -InputObject $body
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode( $ptr )

        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode( $NewPassword )
        Add-Member -Membertype NoteProperty -Name 'newPassword' -value ( [System.Runtime.InteropServices.Marshal]::PtrToStringUni( $ptr ) ) -InputObject $body
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode( $ptr )

        Add-Member -Membertype NoteProperty -Name 'forcePasswordChange' -value ($ForcePasswordChange -eq $True) -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'account', '/iam/account/changepassword' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/account/changepassword' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json ).ok

                if ( !$requestResult )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): password changed for account: $Account"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
