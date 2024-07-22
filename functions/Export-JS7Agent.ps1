function Export-JS7Agent
{
<#
.SYNOPSIS
Exports the Agent configuration from JOC Cockpit

.DESCRIPTION
This cmdlet exports the Agent configuration stored with JOC Cockpit to an archive file in .zip or .tar.gz format.

The following REST Web Service API resources are used:

* /agents/export

.PARAMETER AgentIds
Specifies the list of Agent IDs for Agents that should be exported.

If the Agent ID of an Agent Cluster is specified then all included Subagents and Subagent Clusters will be exported.

.PARAMETER ControllerId
Specifies the ID of the Controller to which objects should be deployed after external signing.
This parameter is required if the -ForSigning parameter is used.

.PARAMETER FilePath
Specifies the path to the archive file that the exported inventory objects are written to.

.PARAMETER Format
Specifies the type of the archive file that will be returned: ZIP, TAR_GZ.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This parameter is not mandatory. However, the JOC Cockpit can be configured to require Audit Log comments for all interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined objects.

.OUTPUTS
This cmdlet returns an octet-stream that can be piped to an output file, e.g. with the Out-File cmdlet.

.EXAMPLE
Export-JS7Agent -ControllerId testsuite -AgentId agent_001,agent_002,agent_cluster_001 -FilePath ./export.zip

Exports the configuration of indicated Agents to the file specified

.EXAMPLE
Get-JS7Agent -ControllerId testsuite | Export-JS7Agent -FilePath ./export.zip

Exports to the file specified the configuration of all Agents registered wiith the given Controller

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $FilePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ZIP','TAR_GZ',IgnoreCase = $False)]
    [string] $Format = 'ZIP',
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

        $formats = @{ 'ZIP' = 'zip'; 'TAR_GZ' = 'tar.gz' }
        $exportControllerIds = @()
        $exportAgentIds = @()
    }

    Process
    {
        if ( $ControllerId )
        {
            $exportControllerIds += $ControllerId
        }

        if ( $AgentId )
        {
            $exportAgentIds += $AgentId
        }
    }

    End
    {
        $body = New-Object PSObject

        if ( $exportControllerIds )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $exportControllerIds -InputObject $body
        }

        if ( $exportAgentIds )
        {
            Add-Member -Membertype NoteProperty -Name 'agentIds' -value $exportAgentIds -InputObject $body
        }

            $exportFile = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'format' -value "$Format" -InputObject $exportFile

            if ( $FilePath )
            {
                Add-Member -Membertype NoteProperty -Name 'filename' -value "$([System.IO.Path]::GetFileName($FilePath))" -InputObject $exportFile
            } else {
                Add-Member -Membertype NoteProperty -Name 'filename' -value "joc-export.$($formats.Item($Format))" -InputObject $exportFile
            }

        Add-Member -Membertype NoteProperty -Name 'exportFile' -value $exportFile -InputObject $body

        if ( $FilePath -and (Test-Path -Path $FilePath -PathType Leaf) )
        {
            Remove-Item -Path $FilePath -Force
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

        if ( $FilePath -and (Test-Path -Path $FilePath -PathType Leaf) )
        {
            Remove-Item -Path $FilePath -Force
        }

        # not used with Invoke-WebRequest -OutFile
        # $headers = @{'Accept' = 'application/json, text/plain, */*'; 'Accept-Encoding' = 'gzip, deflate'; 'Content-Disposition' = "attachment; filename*=UTF-8''joc-export.zip" }
        $headers = @{'Accept' = 'application/json, text/plain, */*'; 'Accept-Encoding' = 'gzip, deflate'}

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/agents/export' -Body $requestBody -Headers $headers -OutFile $FilePath

        if ( Test-Path -Path $FilePath -PathType Leaf )
        {
            if ( isPowerShellVersion 6 )
            {
                $bytes = Get-Content $FilePath -AsByteStream -TotalCount 1
            } else {
                $bytes = Get-Content $FilePath -Encoding byte -TotalCount 1
            }

            # if first character is { (7B, 123) then this indicates a JSON response holding an error
            if ( $bytes -eq '123' )
            {
                throw "$($MyInvocation.MyCommand.Name): error occurred: $(Get-Content $FilePath -Encoding UTF8 -TotalCount 200)"
            }
        } else {
            throw "$($MyInvocation.MyCommand.Name): error occurred:`n$($response | Format-List -Force | Out-String)"
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($exportObjects.count) items exported"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
