function Publish-JS7DeployableObject
{
<#
.SYNOPSIS
Deploys a configuration object such as a workflow to a number of JS7 Controllers.

.DESCRIPTION
This cmdlet deploys a configuration object to a number of JS7 Controllers.

.PARAMETER Path
Specifies the directory, sub-directories and name of the object, e.g. a workflow path.

.PARAMETER Type
Specifies the object type which is one of: 

* WORKFLOW
* JOBCLASS
* LOCK
* JUNCTION

.PARAMETER ControllerId
Specifies one or more Controllers to which the indicated objects should be deployed.

.PARAMETER Delete
Specifies the action to permanently delete objects from a Controller. Withtout this switch objects
are published for use with a Controller.

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
Publish-JS7DeployableObject -ControllerId testsuite,standalone -Path /TestCases/sampleWorkflow_001 -Type 'WORKFLOW'

Deploys the specified workflow to the indicated path to both Controller instances.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBCLASS','LOCK','JUNCTION')]
    [string] $Type,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $ControllerId,
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
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
        
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/deployable' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $deployableObject = ( $response.Content | ConvertFrom-JSON ).deployable
            
            if ( !$deployableObject.id )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Delete )
        {
            $deleteObjects += @{ 'path' = $Path; 'type' = $Type; 'id' = $deployableObject.id }
        } else {
            $storeObjects += @{ 'path' = $Path; 'type' = $Type; 'id' = $deployableObject.id }
        }
    }

    End
    {
        if ( $storeObjects.count -or $deleteObjects.count )
        {
            $body = New-Object PSObject

            
            $objects = @()
            foreach( $controller in $ControllerId )
            {
                $controllerObject = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'controller' -value $controller -InputObject $controllerObject
                $objects += $controllerObject
            }

            Add-Member -Membertype NoteProperty -Name 'controllers' -value $objects -InputObject $body

        
            $objects = @()
            foreach( $object in $storeObjects )
            {
                $storeObject = New-Object PSObject
                # Add-Member -Membertype NoteProperty -Name 'objectType' -value $object.type -InputObject $storeObject
                # Add-Member -Membertype NoteProperty -Name 'path' -value $object.path -InputObject $storeObject
                Add-Member -Membertype NoteProperty -Name 'configurationId' -value $object.id -InputObject $storeObject
                $objects += $storeObject
            }
    
            Add-Member -Membertype NoteProperty -Name 'update' -value $objects -InputObject $body


            $objects = @()
            foreach( $object in $deleteObjects )
            {
                $deleteObject = New-Object PSObject
                # Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $deleteObject
                # Add-Member -Membertype NoteProperty -Name 'path' -value $controllers -InputObject $deleteObject
                Add-Member -Membertype NoteProperty -Name 'configurationId' -value $object.id -InputObject $deleteObject
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
            $response = Invoke-JS7WebRequest -Path '/inventory/deployment/deploy' -Body $requestBody

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
        
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): object deployed"                
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no object deployed"                
        }

        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
