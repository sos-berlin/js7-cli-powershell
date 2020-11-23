function Publish-JS7ReleasableObject
{
<#
.SYNOPSIS
Releases a configuration object such as a schedule

.DESCRIPTION
This cmdlet releases a configuration object for use with a JS7 Controller.

.PARAMETER Path
Specifies the directory, sub-directories and name of the object, e.g. a schedule path.

.PARAMETER Type
Specifies the object type which is one of: 

* ORDERTEMPLATE
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR

.PARAMETER Delete
Specifies the action to permanently delete previously removed objects. 
Withtout this switch objects are released for use with a JS7 Controller.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforece Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined job objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Publish-JS7ReleasableObject -Path /TestCases/sampleSchedule001 -Type 'ORDERTEMPLATE'

Releases the specified schedule with the indicated path for use with a JS7 Controller.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('ORDERTEMPLATE','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR')]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Delete,
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
        $stopWatch = Start-StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
        
        $storeObjects = @()
        $deleteObjects = @()
    }
    
    Process
    {
        if ( $Delete )
        {
            $deleteObjects += @{ 'path' = $Path; 'type' = $Type }
        } else {
            $storeObjects += @{ 'path' = $Path; 'type' = $Type }
        }
    }

    End
    {
        if ( $storeObjects.count -or $deleteObjects.count )
        {
            $body = New-Object PSObject
            
            $objects = @()
        
            $objects = @()
            foreach( $object in $storeObjects )
            {
                $storeObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $storeObject
                Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $storeObject
                $objects += $storeObject
            }
    
            Add-Member -Membertype NoteProperty -Name 'update' -value $objects -InputObject $body


            $objects = @()
            foreach( $object in $deleteObjects )
            {
                $deleteObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $deleteObject
                Add-Member -Membertype NoteProperty -Name 'path' -value $controllers -InputObject $deleteObject
                $objects += $deleteObject
            }
    
            Add-Member -Membertype NoteProperty -Name 'delete' -value $objects -InputObject $body


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
            $response = Invoke-JS7WebRequest -Path '/inventory/release' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-JSON )
                
                if ( !$requestResult.ok )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($storeObjects.count+$deleteObjects.count) objects released"                
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no objects released"                
        }

        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
