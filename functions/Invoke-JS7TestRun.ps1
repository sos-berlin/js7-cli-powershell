function Invoke-JS7TestRun
{
<#
.SYNOPSIS
Performs test runs for JS7.

.DESCRIPTION
The cmdlet is used to automate execution of test cases with JS7.
A test run execution is a loop across a number of test cases for workflows.
Each test case is executed for a number of times that is specified with the -BatchSize parameter (default: 50).
The -Count parameter (default: 1) specifies the number of loops to repeat a test case.
The -SourceDirectory parameter indicates a directory that includes test cases, i.e. .json files for workflows.

Assuming that the source directory with test case files includes 10 workflows then for a -Ccount 5 and
a -BatchSize 100 an overall number of 5000 test cases will be executed in a test run.

When performing test runs by default the cmdlet will perform all steps in a test case lifecycle:

* Prepare: create a test folder in the JOC Cockpit inventory and add test resources such as workflows.
* Run: add orders to the workflows
* Monitor: wait for the test cases to be completed
* Check: check test execution results
* Cleanup: remove any resources of the test case, i.e. any remaining orders and workflows

Each step can be specified individually with the -Prepare, -Run, -Monitor, -Check and -Cleanup parameters.

.PARAMETER ControllerId
Specifies the ID of a JS7 Controller that was used during installation of the product.
If no ID is specified then the first JS7 Controller registered with JOC Cockpit will be used.

.PARAMETER TestRun
Specifies an identifier for the given test run. This identifier is used to create
folders for objects in the JOC Cockpit inventory and it is used to qualify oder IDs.
Choosing a unique identifier simplifies to identify orders created for a given test run
with JOC Cockpit.

.PARAMETER Count
Indicates the number of loops that should be performed for test runs.

.PARAMETER BatchSize
Indicates the number of orders that are added for each test case in a test run loop.

.PARAMETER AtDate
Optionally specifies a date for which the test run should be executed.

If -AtDate is specified then the test run steps to monitor, to check and to cleanup are not performed.
Instead the cmdlet can later on be used with the -Check or -Cleanup parameters to verify test results
and to cleanup test resoures.

.PARAMETER BaseFolder
Specifies the root folder in the JOC Cockpit inventory to which test case resources such as workflows are added.

.PARAMETER SourceArchive
Specifies a source archive file (in .zip or .tar.gz format) that holds .json files for workflows and
related inventory objects.

The archive file can be created by exporting objects from the JOC Cockpit configuration.

.PARAMETER SourceDirectory
Specifies the source directory where test case resources are stored. Test case resources
include .json files for workflows and related inventory objects.

.PARAMETER Recursive
If this parameter is used then the source directory with test case resource files is
traversed recurisvley for any sub-directories.

.PARAMETER WaitInterval
The wait interval is applied when monitoring test runs. It specifies the number of seconds
that the cmdlet will wait before repeating the check for running orders.

.PARAMETER Prepare
A test run lifecycle includes the steps to prepare test case resources, to run test cases, to monitor test case execution,
to check test results and to cleanup test resources.

With this parameter the step to prepare test resources only is executed.

.PARAMETER Run
A test run lifecycle includes the steps to prepare test case resources, to run test cases, to monitor test case execution,
to check test results and to cleanup test resources.

With this parameter the step to run test cases only is executed.

.PARAMETER Monitor
A test run lifecycle includes the steps to prepare test case resources, to run test cases, to monitor test case execution,
to check test results and to cleanup test resources.

With this parameter the step to monitor test case execution only is executed.

.PARAMETER Check
A test run lifecycle includes the steps to prepare test case resources, to run test cases, to monitor test case execution,
to check test results and to cleanup test resources.

With this parameter the step to check test case results only is executed.

.PARAMETER Cleanup
A test run lifecycle includes the steps to prepare test case resources, to run test cases, to monitor test case execution,
to check test results and to cleanup test resources.

With this parameter the step to cleanup test case resources only is executed.

.PARAMETER Progress
Specifies that a progress bar is displayed that provides information about the proceeding of test cases.

This parameter is ignored if the -AtDate parameter is used.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Invoke-JS7TestRun -BaseFolder '/TestRuns' -SourceDirectory "Z:\Documents\PowerShell\jstest\TestCases\Instructions" -Recursive -TestRun Test0000000070

Run test cases from any sub-directories of the specified directory recursively and
wait for completion to check results and to cleanup test data.

.EXAMPLE
Invoke-JS7TestRun -BaseFolder '/TestRuns' -SourceDirectory "Z:\Documents\PowerShell\jstest\testcases\instructions" -Recursive -TestRun Test0000000070 -Prepare -Run

Run test cases for the "prepare" and "run" steps only, i.e. the completion of
test cases is not waited for and no cleanup is performed.

.EXAMPLE
Invoke-JS7TestRun -BaseFolder '/TestRuns' -TestRun Test0000000070 -Cleanup

Do not run test cases but perform the "cleanup" step only, i.e. erase the test data from JOC Cockpit.

.EXAMPLE
Invoke-JS7TestRun -TestRun Test0000000068 -BaseFolder '/TestRuns' -SourceDirectory "Z:\Documents\PowerShell\jstest\testcases\instructions" -Count 1 -AtDate "2020-12-31 01:02:03"

Run a single test case by modifying the batch size to 1 (Default: 100)

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $TestRun = 'Test0000000000',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Count = 1,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $BatchSize  = 100,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $AtDate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $BaseFolder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SourceArchive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SourceDirectory,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $WaitInterval  = 10,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Prepare,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Run,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Monitor,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Check,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Cleanup,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Progress
)

    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$Prepare -and !$Run -and !$Monitor -and !$Check -and !$Cleanup )
        {
            $Prepare = $True
            $Run = $True
            $Monitor = $True
            $Check = $True
            $Cleanup = $True
        }
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name)"

        if ( !$BaseFolder -and ( $Prepare -or $Cleanup ) )
        {
            throw "$($MyInvocation.MyCommand.Name): no base folder specified, use -BaseFolder"
        }

        if ( !$SourceArchive -and !$SourceDirectory -and $Prepare )
        {
            throw "$($MyInvocation.MyCommand.Name): no source archive or source directory for test cases specified, use -SourceArchive or -SourceDirectory"
        }

        if ( !$ControllerId )
        {
            $ControllerId = $script:jsWebService.ControllerId
        }

        # 0. configure
        if ( $BaseFolder.endsWith( '/' ) )
        {
            $BaseFolder = $BaseFolder.Substring( 0, $BaseFolder.Length-1 )
        }

        $testFolder = "$BaseFolder/$TestRun"

        # 1. prepare test case resources
        if ( $Prepare )
        {
            Add-JS7Folder -Path $testFolder

            if ( !$SourceArchive )
            {
                $SourceArchive = New-TemporaryFile
                Write-Verbose ".. creating temporary archive file: $SourceArchive"
                if ( $Recursive )
                {
                    Compress-Archive -DestinationPath $SourceArchive -Path "$($SourceDirectory)/*" -Force
                } else {
                    Compress-Archive -DestinationPath $SourceArchive -Path "$($SourceDirectory)/*.*" -Force
                }
            }

            Import-JS7InventoryItem -FilePath $SourceArchive -TargetFolder $testFolder -Suffix 'imported'
            Publish-JS7DeployableItem -ControllerId $ControllerId -Folder $testFolder -Recursive
            Publish-JS7ReleasableItem -Folder $testFolder -Recursive

            if ( $Run )
            {
                Start-Sleep -Seconds 3
            }
        }

        # 2. run test case
        if ( $Run )
        {
            $addOrderParams = @{}
            $addOrderParams.Add( 'OrderName', $TestRun )

            if ( $AtDate )
            {
                $addOrderParams.Add( 'AtDate', $AtDate )
            }

            if ( $Count -le $BatchSize )
            {
                $testCountOuter = $Count
                $testCountInner = $BatchSize
            } elseif ( ($Count % $BatchSize) -eq 0 ) {
                $testCountOuter = ($Count / $BatchSize)
                $testCountInner = $BatchSize
            } else {
                $testCountOuter = $Count
                $testCountInner = 1
            }

            $workflows = Get-JS7Workflow -Folder $testFolder -Recursive
            $sum = ($workflows.count*$testCountOuter*$testCountInner)
            $cur = 0

            Write-Verbose ".. performing $sum test runs with batches of $($workflows.count) workflows with $testCountOuter outer loops for $testCountInner inner loops"

            foreach( $workflow in $workflows )
            {
                if ( $workflow.type -eq 'WORKFLOW' )
                {
                    $variables = @{}

                    if ( $workflow.orderRequirements -and $workflow.orderRequirements.parameters )
                    {
                        $variableProperties = ( $workflow.orderRequirements.parameters | Get-Member -MemberType NoteProperty )

                        for( $i=0; $i -le $variableProperties.count; $i++ )
                        {
                            $variable = $workflow.orderRequirements.parameters."$($variableProperties[$i].name)"
                            if ( !$variable.default )
                            {
                               if ( $variable.type -eq 'Boolean' )
                               {
                                   $variables.Add( $variableProperties[$i].name, $True )
                               } elseif ( $variable.type -eq 'String' ) {
                                   $variables.Add( $variableProperties[$i].name, 'some string' )
                               } elseif ( $variable.type -eq 'Number' ) {
                                   $variables.Add( $variableProperties[$i].name, 1 )
                               }
                            }
                        }
                    }
                    for( $i=1; $i -le $testCountOuter; $i++ )
                    {
                        $cur++
                        Write-Verbose ".. batches: $cur, object loops: $i, executing: 1..$testCountInner | Add-JS7Order -WorkflowPath $($workflow.path) -OrderName $TestRun -AtDate $AtDate"
                        1..$testCountInner | Add-JS7Order -WorkflowPath $workflow.path -Variables $variables @addOrderParams | Out-Null
#                       1..$testCountInner | Add-JS7Order -WorkflowPath $workflow.path -Variables $variables -OrderName "$($TestRun)-$([DateTimeOffset]::Now.ToUnixTimeMilliSeconds())" @addOrderParams | Out-Null
#                       1..$testCountInner | Add-JS7Order -WorkflowPath $workflow.path -Variables $variables -OrderName "$($TestRun)-$(Get-Random)" @addOrderParams | Out-Null
                        if ( $Progress )
                        {
                            Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -CurrentOperation "adding orders ..." -Status "$($cur*$testCountInner) of $sum orders added" -PercentComplete (($cur/$sum)*100) -SecondsRemaining -1
                        }
                    }
                }
            }
        }

        # 3. monitor test case execution
        if ( $Monitor -and !$AtDate )
        {
            Do {
                for( $i=1; $i -le $WaitInterval; $i++ )
                {
                    if ( $Progress )
                    {
                        Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -CurrentOperation "waiting for orders to complete ..." -Status "$($i)s of $($WaitInterval)s waiting" -PercentComplete ($WaitInterval/$i) -SecondsRemaining -1
                    }
                    Start-Sleep -Seconds 1
                }

                $orders = Get-JS7Order -RegularExpression "$TestRun`$"
                if ( $orders.count )
                {
                    Write-Output ".. number of orders in processing: $($orders.count)"
                }
            } While ( $orders.count )
        }

        if ( $Progress )
        {
            Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun"
        }

        # 4. check test execution results
        if ( $Check -and !$AtDate )
        {
            if ( $Progress )
            {
                Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -CurrentOperation "checking order execution state ..." -Status "1 of 2 steps to check state: IN PROGRESS" -PercentComplete (0/2) -SecondsRemaining -1
            }

            $ordersInProgress = Get-JS7OrderHistory -RegularExpression "$TestRun`$" | Where-Object { $_.state._text -eq 'INCOMPLETE' }
            if ( $ordersInProgress.count )
            {
                Write-Output ".. $($ordersInProgress.count) orders found with state: IN PROGRESS"
            }

            if ( $Progress )
            {
                Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -CurrentOperation "checking order execution state ..." -Status "2 of 2 steps to check state: FAILED" -PercentComplete (1/2) -SecondsRemaining -1
            }

            $ordersFailed = Get-JS7OrderHistory -RegularExpression "$TestRun`$" | Where-Object { $_.state._text -eq 'FAILED' }

            if ( $ordersFailed.count )
            {
                Write-Error "$($ordersFailed.count) orders found with state: FAILED"
            }
        }
    }

    End
    {
        # 5. cleanup test case resources
        if ( $Cleanup -and !$AtDate )
        {
            if ( $Progress )
            {
                Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -CurrentOperation "cleaning up ..." -Status "1 of 2 steps to cancel remaining orders" -PercentComplete (0/2) -SecondsRemaining -1
            }

            $orders = Get-JS7Order -RegularExpression "$TestRun`$"

            if ( $orders.count )
            {
                Write-Output ".. $($orders.count) orders found to cancel"
                $orders | Stop-JS7Order -Kill
            }

            if ( $Progress )
            {
                Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -CurrentOperation "cleaning up ..." -Status "2 of 2 steps to delete test data" -PercentComplete (0/2) -SecondsRemaining -1
            }

            # Drop test run folder with any includes resources
            Remove-JS7Folder -Path $testFolder
            # Publish-JS7DeployableItem -ControllerId $ControllerId -Path $testFolder -Type FOLDER -Delete

            if ( $Progress )
            {
                Write-Progress -Id 1 -Activity "JS7 Test Run: $TestRun" -Completed
            }
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
