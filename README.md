# JS7 PowerShell Command Line Interface

The JS7 Command Line Interface (CLI) can be used to manage
JS7 instances (restart, stop, status) and workflow related objects.

The JS7 CLI module supports Windows PowerShell FullCLR 5.1 and PowerShell CoreCLR 6.x and 7.x for Windows, Linux and MacOS environments.

# Purpose

The JS7 Command Line Interface is used for the following 
areas of operation:

* provide bulk operations:
    * deploy workflows and related object such as junctions and locks
    * submit orders, suspend and cancel orders
    * manage the daily plan by creating and removing orders
* schedule orders:
    * add orders to workflows
    * start orders
* manage Agents:
    * retrieve Agent status information
    * report Agent job executions
 
Find more information and documentation of cmdlets at [PowerShell Command Line Interface](https://kb.sos-berlin.com/x/PpQwAw)

# Getting Started

## Prerequisites

### Check Execution Policy

* `PS > Get-ExecutionPolicy`
 * shows the current execution policy, see e.g. [Microsoft Technet about_Execution_Policies](https://technet.microsoft.com/en-us/library/hh847748.aspx)
 * The required PowerShell execution policy for the JS7 CLI module is *RemoteSigned* or *Unrestricted*
* `PS > Set-ExecutionPolicy RemoteSigned`
 * Modifying the execution policy might require administrative privileges

### Check Module Location

* PowerShell provides a number of locations for modules, see $env:PSModulePath for predefined module locations.
* Download/unzip the JS7 CLI module 
 * either to a user's module location, e.g. for Windows `C:\Users\<user-name>\Documents\WindowsPowerShell\Modules\` or `/home/<user-name>/.local/share/powershell/Modules` for a Linux environment
 * or to a location that is available for all users, e.g. `C:\Windows\system32\WindowsPowerShell\v1.0\Modules\`
 * or to an arbitrary location that later on is specified when importing the module.
* Directory names might differ according to PowerShell versions.
* The required JS7 CLI module folder name is *JS7*. If you download the module it is wrapped in a folder that specifies the current branch, e.g. *js7-cli-powershell-2.0.0*. Manually create the *JS7* folder in the module location and add the contents of the *js7-cli-powershell-2.0.0* folder from the archive.

## Import Module

* `PS > Import-Module JS7`
  * loads the module from a location that is available with the PowerShell module path, see $env:PSModulePath for predefined module locations.
* `PS > Import-Module C:\some_path\JS7`
  * loads the module from a specific location.

Hint: you can add the `Import-Module` command to your PowerShell user profile to have the module imported on start up of a PowerShell session.

## Use Web Service

As a first operation after importing the module it is recommended to execute the Connect-JS7 cmdlet:

* `PS > Connect-JS7 <Url> -AskForCredentials`
 * specifies the URL of JOC Cockpit, e.g. http://localhost:4446, and aks interactively for credentials. The default acount is `root` with the password `root`.
* `PS > Connect-JS7 <Url> <Credentials> <ControllerId>`  or  `PS > Connect-JS7 -Url <Url> -Credentials <Credentials> -Id <ControllerId>`
 * specifies the URL for which JOC Cockpit is available. This is the same URL that you would use when opening the JOC Cockpit GUI in your browser, e.g. `http://localhost:4446`. When omitting the protocol (http/https) for the URL then http is assumed.
 * specifies the ID that a JS7 Controller has been installed with. As JOC Cockpit can manage a number of Controller instances the `-Id` parameter can be used to select the respective Controller.
 * specifies the credentials (user account and password) that are used to connect to the Web Service.
   * A credential object can be created by keyboard input like this:
     * `Set-JS7Credentials -AskForCredentials`
   * A credential object can be created like this:
     * `$credentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'root', ( 'root' | ConvertTo-SecureString -AsPlainText -Force) )`
     * The example makes use of the default account "root" and password "root".
     * A possible location for the above code is a user's PowerShell Profile that would be executed for a PowerShell session.
   * Credentials can be forwarded with the Url parameter like this: 
     * `Connect-JS7 -Url http://root:root@localhost:4446 -Id ControllerId`
     * Specifying account and password with a URL is considered insecure.
 * allows to execute cmdlets for the specified JS7 Controller independently from the server and operating system that the Controller is operated for, i.e. you can use PowerShell cmdlets on Windows to manage a JS7 Controller running e.g. on a Linux box and vice versa.
 * specifying the URL is not sufficient to connect to the Windows Web Service of a Controller, see below.

## Run Commands

The JS7 CLI provides a number of cmdlets, see [PowerShell CLI - Cmdlets](https://kb.sos-berlin.com/x/fpQwAw). Return values of cmdlets generally correspond to the JOC Cockpit [REST Web Service](https://www.sos-berlin.com/JOC/2.0.0/raml-doc/JOC-API/index.html).

* `PS > Get-Command -Module JS7`
    * The complete list of cmdlets is available with this command.
* `PS > Get-JS7ControllerStatus`
    * Cmdlets come with a full name that includes the term JS7.
* `PS > Get-JSControllerStatus`
    * The term JS7 can be abbreviated to JS.
* `PS > Get-Status`
    * The term JS7 can further be omitted if the resulting alias does not conflict with existing cmdlets.
    * To prevent conflicts with existing cmdlets from other modules no conflicting aliases are created. This includes aliases for cmdlets from the PowerShell Core as e.g. Get-Job, Start-Job, Stop-Job etc. and cmdlets from other modules loaded prior to the JS7 CLI.
* `PS > Get-Help Get-JS7ControllerStatus -detailed`
  * displays help information for the given cmdlet.

# Examples

* `PS > Get-JS7ControllerStatus -Display -Summary`
  * returns the summary information for a JS7 Controller.
* `PS > (Get-JS7Workflow).count`
  * returns the number of workflows that are available.
* `PS > (Get-JS7Job).count`
  * returns the number of jobs that are available.
* `PS > (Get-JS7ControllerStatus -Summary)JobSummary.running.count`
  * returns the number of tasks that are currently running.
* `PS > Get-JS7Order -Folder /sos -Running | Suspend-JS7Order`
  * suspends all running orders from the specified folder.
* `PS > Get-JS7Order | Suspend-JS7Order`
  * performs and emergency stop and kills all running tasks.
* `PS > $orders = ( Get-JS7Order -Folder /my_workflows -Recursive | Suspend-JS7Order )`
  * retrieves orders from the *my_jobs* folder and any sub-folders with orders found being suspended. The list of affected orders is returned.
* `PS > $orders | Stop-JS7Order`
  * remove orders based on a list that has previously been retrieved.

# Manage Log Output

JS7 cmdlets consider verbosity and debug settings.

* `PS > $VerbosePreference = "Continue"`
    * This will cause verbose output to be created from cmdlets.
* `PS > $VerbosePreference = "SilentlyContinue"`
    * The verbosity level is reset.
* `PS > $DebugPreference = "Continue"`
    * This will cause debug output to be created from cmdlets.
* `PS > $DebugPreference = "SilentlyContinue"`
    * The debug level is reset.
 
# Further Reading

* [PowerShell Command Line Interface - Introduction](https://kb.sos-berlin.com/x/PpQwAw)
* [PowerShell Command Line Interface - Use Cases](https://kb.sos-berlin.com/x/95swAw)
* [PowerShell Command Line Interface - Cmdlets](https://kb.sos-berlin.com/x/fpQwAw)
