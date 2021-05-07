function Send-JS7Mail
{
<#
    .SYNOPSIS
        Send e-mail with a test run summary and diagnostic information
    .DESCRIPTION
        This cmdlet collect diagnostic data such as the log file, the Pester result file,
        the test cases and the deployment files of a test run.
        
        A summary about the test case result (successful/failed) and the diagnostic data
        are forwarded by e-mail.
    .PARAMETER Server
        Host name or IP address of the SMTP mail server.
    .PARAMETER Port
        Numeric port for the e-mail protocol.
        * Basic SMTP frequently makes use of port 25.
        * Explicit SSL frequently makes use of port 587.
        * Implicit SSL frequently makes use of port 465.
    .PARAMETER From
        The e-mail address that sends the information.
    .PARAMETER To
        The recipient of the e-mail
    .PARAMETER Subject
        The subject of the e-mail.
    .PARAMETER Body
        The body of the e-mail. By default the body is plain text. 
        When using html e-mail consider to use the -BodyAsHtml switch.
    .PARAMETER Cc
        The carbon copy recipients of e-mail.
    .PARAMETER Bcc
        The blind carbon copy recipients of e-mail.
    .PARAMETER Attachments
        Accepts an array of file names including the full path that should be attached to the e-mail.
    .PARAMETER Credential
        The credential including user name and password of the account that authenticates with the SMTP mail server.
        This parameter is required only for SMTP mail servers that require authentication.
        
        A credential object is created like this:
        $mailCredential = New-Object System.Net.NetworkCredential( "info@sos-berlin.com", "secret" )
    .PARAMETER Timeout
        The timout in milliseconds that JS7 will wait for the connection to the mail server to be established.
        
        Default: 15000
    .PARAMETER UseSSL
        Forces one of Explicit SSL or Implicit SSL to be used.
        Without this switch e-mail body and credentials will be sent as unencrypted plain text through the network.
    .PARAMETER UseDefaultCredentials
        This parameter specifies that default credentials of the logged in user should be used if
        SMTP authentication is required.
    .EXAMPLE
        Send-JS7Mail -Server 'smtp.example.com' -Port 25 -To 'user@example.com' -Subject 'some subject' -Body '<html><head><body>Hi there</body></head></html>' -BodyAsHtml -UseSSL
    
        Sends an html e-mail via the respective mail server.
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Server,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Port,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $From,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $To,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Subject,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Body,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Cc,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Bcc,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Attachments,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Net.NetworkCredential] $Credential,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Timeout = 15000,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $BodyAsHtml,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $UseSSL,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $UseDefaultCredentials
)
    Process 
    {
        $message = New-Object Net.Mail.MailMessage
        $message.From = $From
        foreach( $item in $To )
		{
			$message.To.Add( $item )
		}
		
        $message.Subject = $Subject
        $message.Body = $Body

        if ( $BodyAsHtml )
        {
            $message.IsBodyHTML = $BodyAsHtml
        }
            
        if ( $Cc )
        {
            foreach( $item in $Cc )
			{
				$message.Cc.Add( $item )
			}
			
        }

        if ( $Bcc )
        {
             foreach( $item in $Bcc )
			{
				$message.Bcc.Add( $item )
			}
        }

        foreach( $attachment in $Attachments )
        {
            $message.Attachments.Add( $attachment )
        }
	
        $smtp = New-Object Net.Mail.SmtpClient( $Server, $Port )
		$smtp.Timeout = $Timeout
    
        if ( $UseSSL )
        {
            $smtp.EnableSSL = $UseSSL
            [System.Net.ServicePointManager]::SecurityProtocol = 'Tls,TLS11,TLS12'
        }

        if ( $Credential )
        {
            # the sequence of these lines is important, see https://github.com/dotnet/runtime/issues/23779
            # UseDefaultCredentials sets the credential to null and has to precede setting Network Credentials
            $smtp.UseDefaultCredentials = $UseDefaultCredentials
            $smtp.Credentials = $Credential
        }

        $smtp.send( $message )
    }
}
