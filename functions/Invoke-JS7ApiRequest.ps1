function Invoke-JS7ApiRequest
{
<#
.SYNOPSIS
Sends a request to the JS7 REST Web Service.

.DESCRIPTION
The JS7 REST Web Service accepts JSON based requests. This cmdlet therefore is generic to allow
any requests to be forwarded to JS7.

.PARAMETER Path
The Path specifies the part of URL that states the operation that is used for the request,
see http://test.sos-berlin.com/JOC/raml-doc/JOC-API/ for a complete list of Paths.

The Path is prefixed by the Base parameter.

* Example: http://localhost:4446/joc/api/tasks/history
* The URL scheme 'http' and authority 'localhost:4446' are used from the connection
  that is specified to the Web Service by the Connect-JS7 cmdlet.
* The Base '/joc/api' is used for all REST Web Service requests.
* The Path '/tasks/history' is used to query the JS7 task history.

.PARAMETER Body
Specifies the request body that is sent to the RESTWeb Service. The body is a PowerShell object that is converted to
a JSON object by the cmdlet:

    $body = New-Object PSObject
    Add-Member -Membertype NoteProperty -Name 'controllerId' -value 'jobscheduler' -InputObject $body
    Add-Member -Membertype NoteProperty -Name 'states' -value @('COUPLED', 'DECOUPLED', 'COUPLINGFAILED') -InputObject $body
    $response = Invoke-JS7ApiRequest -Path '/agents' -Body $body

This request returns information about Agents filtered by the indicated states.

.PARAMETER Method
This parameter specifies the HTTP method in use.

There should be no reason to modify the default value 'POST'.

.PARAMETER ContentType
The HTTP content type is 'application/json' for JSON based requests.

.PARAMETER Headers
A hashtable can be specified with name/value pairs for HTTP headers.
Typically the 'Accept' header is required for use of the REST API.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention,
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured
to enforece Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.OUTPUTS
This cmdlet returns the REST Web Service response.

.EXAMPLE
$body = New-Object PSObject
Add-Member -Membertype NoteProperty -Name 'controllerId' -value 'jobscheduler' -InputObject $body
Add-Member -Membertype NoteProperty -Name 'states' -value @('COUPLED', 'DECOUPLED', 'COUPLINGFAILED') -InputObject $body
$response = Invoke-JS7ApiRequest -Path '/agents' -Body $body

Returns information about Agents filtered by the indicated states.

.EXAMPLE
$response = Invoke-JS7ApiRequest -Path '/controllers'

Returns summary information about Controllers connected to JOC Cockpit.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSObject] $Body,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Method = 'POST',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ContentType = 'application/json',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Headers = @{'Accept' = 'application/json'},
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
        if ( !$Path.startsWith( '/' ) )
        {
            $Path = '/' + $Path
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

            Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $Body
        }

        if ( $Body )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path $Path -Body $requestBody -Method $Method -ContentType $ContentType -Headers $Headers
        } else {
            $response = Invoke-JS7WebRequest -Path $Path -Method $Method -ContentType $ContentType -Headers $Headers
        }

        if ( $response.StatusCode -ne 200 )
        {
            throw ( $response | Format-List -Force | Out-String )
        }

        $response
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
