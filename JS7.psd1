@{

# Script module or binary module file associated with this manifest.
RootModule = 'JS7.psm1'

# Version number of this module.
ModuleVersion = '2.0.31.0'

# ID used to uniquely identify this module
GUID = '904a35e3-39b4-40bf-ab5f-e8c4ad5ae38d'

# Author of this module
Author = 'Andreas Pueschel'

# Company or vendor of this module
CompanyName = 'SOS GmbH'

# Copyright statement for this module
Copyright = 'Copyright (c) 2020 by SOS GmbH, licensed under GPL v3 License.'

# Description of the functionality provided by this module
Description = 'Manage and Control workflows and jobs with JS7 JobScheduler Controller and Agents, access the JS7 REST Web Service API'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Functions to export from this module
FunctionsToExport = @(
    'Add-JS7Folder',
    'Add-JS7GitCredentials',
    'Add-JS7InventoryItem',
    'Add-JS7Order',
    'Add-JS7SigningKey',
    'Add-JS7Tag',
    'Add-JS7TagFolder',
    'Confirm-JS7InventoryFolder',
    'Confirm-JS7Order',
    'Connect-JS7',
    'Disable-JS7Agent',
    'Disable-JS7IAMAccount',
    'Disable-JS7Subagent',
    'Disconnect-JS7',
    'Enable-JS7Agent',
    'Enable-JS7IAMAccount',
    'Enable-JS7Subagent',
    'Export-JS7Agent',
    'Export-JS7InventoryFolder',
    'Export-JS7InventoryItem',
    'Import-JS7InventoryItem',
    'Get-JS7Agent',
    'Get-JS7AgentReport',
    'Get-JS7AgentStatus',
    'Get-JS7AuditLog',
    'Get-JS7Calendar',
    'Get-JS7CalendarDates',
    'Get-JS7ControllerInstance',
    'Get-JS7ControllerStatus',
    'Get-JS7ControllerVersion',
    'Get-JS7DailyPlanOrder',
    'Get-JS7DeployableItem',
    'Get-JS7FileTransferHistory',
    'Get-JS7FileTransferHistoryFile',
    'Get-JS7FileTransferItem',
    'Get-JS7GitCredentials',
    'Get-JS7IAMAccount',
    'Get-JS7IAMFolder',
    'Get-JS7IAMAccountPermission',
    'Get-JS7IAMPermission',
    'Get-JS7IAMRole',
    'Get-JS7IAMService',
    'Get-JS7InventoryChange',
    'Get-JS7InventoryDependencies',
    'Get-JS7InventoryFolder',
    'Get-JS7InventoryItem',
    'Get-JS7InventoryStatistics',
    'Get-JS7ReleasableItem',
    'Get-JS7JOCInstance',
    'Get-JS7JOCLicense',
    'Get-JS7JOCLog',
    'Get-JS7JOCLogFilename',
    'Get-JS7JOCProperties',
    'Get-JS7JOCSettings',
    'Get-JS7JOCVersion',
    'Get-JS7Lock',
    'Get-JS7Notice',
    'Get-JS7NoticeBoard',
    'Get-JS7Notification',
    'Get-JS7NotificationConfiguration',
    'Get-JS7Order',
    'Get-JS7OrderAddPosition',
    'Get-JS7OrderHistory',
    'Get-JS7OrderLog',
    'Get-JS7OrderSnapshot',
    'Get-JS7OrderSummary',
    'Get-JS7RepositoryItem',
    'Get-JS7OrderResumePosition',
    'Get-JS7Schedule',
    'Get-JS7SigningKey',
    'Get-JS7SubagentCluster',
    'Get-JS7SystemCredentials',
    'Get-JS7TaskHistory',
    'Get-JS7TaskLog',
    'Get-JS7Version',
    'Get-JS7Workflow',
    'Hide-JS7Agent',
    'Invoke-JS7ApiRequest',
    'Invoke-JS7Encrypt',
    'Invoke-JS7Decrypt',
    'Invoke-JS7GitRepositoryAdd',
    'Invoke-JS7GitRepositoryCheckout',
    'Invoke-JS7GitRepositoryClone',
    'Invoke-JS7GitRepositoryCommit',
    'Invoke-JS7GitRepositoryPull',
    'Invoke-JS7GitRepositoryPush',
    'Invoke-JS7IAMChangePassword',
    'Invoke-JS7IAMForcePasswordChange',
    'Invoke-JS7IAMResetPassword',
    'Invoke-JS7TestRun',
    'Invoke-JS7WorkflowSigning',
    'New-JS7ControllerInstance',
    'New-JS7DailyPlanOrder',
    'New-JS7SigningKey',
    'New-JS7Subagent',
    'Publish-JS7Agent',
    'Publish-JS7ClusterAgent',
    'Publish-JS7DeployableItem',
    'Publish-JS7ReleasableItem',
    'Publish-JS7SubagentCluster',
    'Remove-JS7Agent',
    'Remove-JS7CompletedOrder',
    'Remove-JS7DailyPlanOrder',
    'Remove-JS7DailyPlanSubmission',
    'Remove-JS7FileTransferItem',
    'Remove-JS7Folder',
    'Remove-JS7GitCredentials',
    'Remove-JS7IAMAccount',
    'Remove-JS7IAMFolder',
    'Remove-JS7IAMPermission',
    'Remove-JS7IAMRole',
    'Remove-JS7IAMService',
    'Remove-JS7InventoryItem',
    'Remove-JS7Notice',
    'Remove-JS7RepositoryItem',
    'Remove-JS7Subagent',
    'Remove-JS7SubagentCluster',
    'Remove-JS7Tag',
    'Remove-JS7TagFolder',
    'Rename-JS7Folder',
    'Rename-JS7IAMAccount',
    'Rename-JS7IAMFolder',
    'Rename-JS7IAMPermission',
    'Rename-JS7IAMRole',
    'Rename-JS7IAMService',
    'Rename-JS7InventoryItem',
    'Reset-JS7Agent',
    'Reset-JS7Job',
    'Reset-JS7Subagent',
    'Restart-JS7ControllerInstance',
    'Restart-JS7JOCService',
    'Restore-JS7Agent',
    'Restore-JS7Folder',
    'Restore-JS7InventoryItem',
    'Resume-JS7Job',
    'Resume-JS7Order',
    'Resume-JS7Workflow',
    'Revoke-JS7ClusterAgent',
    'Revoke-JS7DeployableItem',
    'Revoke-JS7ReleasableItem',
    'Revoke-JS7SubagentCluster',
    'Send-JS7Mail',
    'Set-JS7Agent',
    'Set-JS7ClusterAgent',
    'Set-JS7Controller',
    'Set-JS7Credentials',
    'Set-JS7DailyPlanOrder',
    'Set-JS7Option',
    'Set-JS7Order',
    'Show-JS7Agent',
    'Set-JS7FileTransferItem',
    'Set-JS7IAMAccount',
    'Set-JS7IAMFolder',
    'Set-JS7IAMPermission',
    'Set-JS7IAMRole',
    'Set-JS7IAMService',
    'Set-JS7InventoryItem',
    'Set-JS7JobResource',
    'Set-JS7JOCSettings',
    'Set-JS7NotificationConfiguration',
    'Set-JS7RepositoryItem',
    'Set-JS7Subagent',
    'Set-JS7SubagentCluster',
    'Skip-JS7Job',
    'Start-JS7ExecutableFile',
    'Start-JS7Order',
    'Stop-JS7ControllerInstance',
    'Stop-JS7DailyPlanOrder',
    'Stop-JS7Order',
    'Submit-JS7DailyPlanOrder',
    'Submit-JS7Notice',
    'Suspend-JS7Job',
    'Suspend-JS7Order',
    'Suspend-JS7Workflow',
    'Switch-JS7ControllerInstance',
    'Switch-JS7JOCInstance',
    'Test-JS7ControllerInstance',
    'Update-JS7FromRepositoryItem'
)

# # Cmdlets to export from this module
# CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = @()

# # Aliases to export from this module
# AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

PrivateData = @{
    # PSData is module packaging and gallery metadata embedded in PrivateData
    # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
    # We had to do this because it's the only place we're allowed to extend the manifest
    # https://connect.microsoft.com/PowerShell/feedback/details/421837
    PSData = @{
        # The primary categorization of this module (from the TechNet Gallery tech tree).
        Category = "Scripting Techniques"

        # Keyword tags to help users find this module via navigations and search.
        Tags = @('PSEdition_Desktop','PSEdition_Core','Windows','Linux','MacOS','Cmdlet','Workflow','JobScheduler','JS7','Scheduling','Workload-Automation')

        # The web address of an icon which can be used in galleries to represent this module
        IconUri = "https://kb.sos-berlin.com/download/attachments/3638359/JS7_blue_orange_on_white.png?api=v2"

        # The web address of this module's project or support homepage.
        ProjectUri = "https://kb.sos-berlin.com/x/PpQwAw"

        # The web address of this module's license. Points to a page that's embeddable and linkable.
        LicenseUri = "https://www.gnu.org/licenses/gpl-3.0.en.html"

        # Release notes for this particular version of the module
        # ReleaseNotes = False

        # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
        # RequireLicenseAcceptance = ""

        # Indicates this is a pre-release/testing version of the module.
        IsPrerelease = 'False'
    }
}

# HelpInfo URI of this module
HelpInfoURI = 'https://kb.sos-berlin.com/x/fpQwAw'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

# SIG # Begin signature block
# MIIs0AYJKoZIhvcNAQcCoIIswTCCLL0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBBCxPIa5+GPWTB
# k+Hn9Ohiz71Xx1yDHzEAvijN3qkW3KCCJd8wggVvMIIEV6ADAgECAhBI/JO0YFWU
# jTanyYqJ1pQWMA0GCSqGSIb3DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# DBJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoM
# EUNvbW9kbyBDQSBMaW1pdGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2Vy
# dmljZXMwHhcNMjEwNTI1MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjBWMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN55QSIgQkdC7/FiMCkoq2rjaFrEfUI5ErPtx94jGgUW+s
# hJHjUoq14pbe0IdjJImK/+8Skzt9u7aKvb0Ffyeba2XTpQxpsbxJOZrxbW6q5KCD
# J9qaDStQ6Utbs7hkNqR+Sj2pcaths3OzPAsM79szV+W+NDfjlxtd/R8SPYIDdub7
# P2bSlDFp+m2zNKzBenjcklDyZMeqLQSrw2rq4C+np9xu1+j/2iGrQL+57g2extme
# me/G3h+pDHazJyCh1rr9gOcB0u/rgimVcI3/uxXP/tEPNqIuTzKQdEZrRzUTdwUz
# T2MuuC3hv2WnBGsY2HH6zAjybYmZELGt2z4s5KoYsMYHAXVn3m3pY2MeNn9pib6q
# RT5uWl+PoVvLnTCGMOgDs0DGDQ84zWeoU4j6uDBl+m/H5x2xg3RpPqzEaDux5mcz
# mrYI4IAFSEDu9oJkRqj1c7AGlfJsZZ+/VVscnFcax3hGfHCqlBuCF6yH6bbJDoEc
# QNYWFyn8XJwYK+pF9e+91WdPKF4F7pBMeufG9ND8+s0+MkYTIDaKBOq3qgdGnA2T
# OglmmVhcKaO5DKYwODzQRjY1fJy67sPV+Qp2+n4FG0DKkjXp1XrRtX8ArqmQqsV/
# AZwQsRb8zG4Y3G9i/qZQp7h7uJ0VP/4gDHXIIloTlRmQAOka1cKG8eOO7F/05QID
# AQABo4IBEjCCAQ4wHwYDVR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYD
# VR0OBBYEFDLrkpr/NZZILyhAQnAgNpFcF4XmMA4GA1UdDwEB/wQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYE
# VR0gADAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21v
# ZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEE
# KDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZI
# hvcNAQEMBQADggEBABK/oe+LdJqYRLhpRrWrJAoMpIpnuDqBv0WKfVIHqI0fTiGF
# OaNrXi0ghr8QuK55O1PNtPvYRL4G2VxjZ9RAFodEhnIq1jIV9RKDwvnhXRFAZ/ZC
# J3LFI+ICOBpMIOLbAffNRk8monxmwFE2tokCVMf8WPtsAO7+mKYulaEMUykfb9gZ
# pk+e96wJ6l2CxouvgKe9gUhShDHaMuwV5KZMPWw5c9QLhTkg4IUaaOGnSDip0TYl
# d8GNGRbFiExmfS9jzpjoad+sPKhdnckcW67Y8y90z7h+9teDnRGWYpquRRPaf9xH
# +9/DUp/mBlXpnYzyOmJRvOwkDynUWICE5EV7WtgwggWNMIIEdaADAgECAhAOmxiO
# +dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAw
# MDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsb
# hA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iT
# cMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGb
# NOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclP
# XuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCr
# VYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFP
# ObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTv
# kpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWM
# cCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls
# 5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBR
# a2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6
# MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8E
# BAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDig
# NoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCg
# v0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQT
# SnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh
# 65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSw
# uKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAO
# QGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjD
# TZ9ztwGpn1eqXijiuZQwggYcMIIEBKADAgECAhAz1wiokUBTGeKlu9M5ua1uMA0G
# CSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExp
# bWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBSb290
# IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5NTlaMFcxCzAJBgNVBAYT
# AkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28g
# UHVibGljIENvZGUgU2lnbmluZyBDQSBFViBSMzYwggGiMA0GCSqGSIb3DQEBAQUA
# A4IBjwAwggGKAoIBgQC70f4et0JbePWQp64sg/GNIdMwhoV739PN2RZLrIXFuwHP
# 4owoEXIEdiyBxasSekBKxRDogRQ5G19PB/YwMDB/NSXlwHM9QAmU6Kj46zkLVdW2
# DIseJ/jePiLBv+9l7nPuZd0o3bsffZsyf7eZVReqskmoPBBqOsMhspmoQ9c7gqgZ
# YbU+alpduLyeE9AKnvVbj2k4aOqlH1vKI+4L7bzQHkNDbrBTjMJzKkQxbr6PuMYC
# 9ruCBBV5DFIg6JgncWHvL+T4AvszWbX0w1Xn3/YIIq620QlZ7AGfc4m3Q0/V8tm9
# VlkJ3bcX9sR0gLqHRqwG29sEDdVOuu6MCTQZlRvmcBMEJd+PuNeEM4xspgzraLqV
# T3xE6NRpjSV5wyHxNXf4T7YSVZXQVugYAtXueciGoWnxG06UE2oHYvDQa5mll1Ce
# HDOhHu5hiwVoHI717iaQg9b+cYWnmvINFD42tRKtd3V6zOdGNmqQU8vGlHHeBzoh
# +dYyZ+CcblSGoGSgg8sCAwEAAaOCAWMwggFfMB8GA1UdIwQYMBaAFDLrkpr/NZZI
# LyhAQnAgNpFcF4XmMB0GA1UdDgQWBBSBMpJBKyjNRsjEosYqORLsSKk/FDAOBgNV
# HQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEF
# BQcDAzAaBgNVHSAEEzARMAYGBFUdIAAwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6g
# PIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25p
# bmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6
# Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nUm9vdFI0
# Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqG
# SIb3DQEBDAUAA4ICAQBfNqz7+fZyWhS38Asd3tj9lwHS/QHumS2G6Pa38Dn/1oFK
# WqdCSgotFZ3mlP3FaUqy10vxFhJM9r6QZmWLLXTUqwj3ahEDCHd8vmnhsNufJIkD
# 1t5cpOCy1rTP4zjVuW3MJ9bOZBHoEHJ20/ng6SyJ6UnTs5eWBgrh9grIQZqRXYHY
# NneYyoBBl6j4kT9jn6rNVFRLgOr1F2bTlHH9nv1HMePpGoYd074g0j+xUl+yk72M
# lQmYco+VAfSYQ6VK+xQmqp02v3Kw/Ny9hA3s7TSoXpUrOBZjBXXZ9jEuFWvilLIq
# 0nQ1tZiao/74Ky+2F0snbFrmuXZe2obdq2TWauqDGIgbMYL1iLOUJcAhLwhpAuNM
# u0wqETDrgXkG4UGVKtQg9guT5Hx2DJ0dJmtfhAH2KpnNr97H8OQYok6bLyoMZqaS
# dSa+2UA1E2+upjcaeuitHFFjBypWBmztfhj24+xkc6ZtCDaLrw+ZrnVrFyvCTWrD
# UUZBVumPwo3/E3Gb2u2e05+r5UWmEsUUWlJBl6MGAAjF5hzqJ4I8O9vmRsTvLQA1
# E802fZ3lqicIBczOwDYOSxlP0GOabb/FKVMxItt1UHeG0PL4au5rBhs+hSMrl8h+
# eplBDN1Yfw6owxI9OjWb4J0sjBeBVESoeh2YnZZ/WVimVGX/UUIL+Efrz/jlvzCC
# BrQwggScoAMCAQICEA3HrFcF/yGZLkBDIgw6SYYwDQYJKoZIhvcNAQELBQAwYjEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0
# MB4XDTI1MDUwNzAwMDAwMFoXDTM4MDExNDIzNTk1OVowaTELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVz
# dGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALR4MdMKmEFyvjxGwBysddujRmh0
# tFEXnU2tjQ2UtZmWgyxU7UNqEY81FzJsQqr5G7A6c+Gh/qm8Xi4aPCOo2N8S9SLr
# C6Kbltqn7SWCWgzbNfiR+2fkHUiljNOqnIVD/gG3SYDEAd4dg2dDGpeZGKe+42DF
# UF0mR/vtLa4+gKPsYfwEu7EEbkC9+0F2w4QJLVSTEG8yAR2CQWIM1iI5PHg62IVw
# xKSpO0XaF9DPfNBKS7Zazch8NF5vp7eaZ2CVNxpqumzTCNSOxm+SAWSuIr21Qomb
# +zzQWKhxKTVVgtmUPAW35xUUFREmDrMxSNlr/NsJyUXzdtFUUt4aS4CEeIY8y9Ia
# aGBpPNXKFifinT7zL2gdFpBP9qh8SdLnEut/GcalNeJQ55IuwnKCgs+nrpuQNfVm
# UB5KlCX3ZA4x5HHKS+rqBvKWxdCyQEEGcbLe1b8Aw4wJkhU1JrPsFfxW1gaou30y
# Z46t4Y9F20HHfIY4/6vHespYMQmUiote8ladjS/nJ0+k6MvqzfpzPDOy5y6gqzti
# T96Fv/9bH7mQyogxG9QEPHrPV6/7umw052AkyiLA6tQbZl1KhBtTasySkuJDpsZG
# Kdlsjg4u70EwgWbVRSX1Wd4+zoFpp4Ra+MlKM2baoD6x0VR4RjSpWM8o5a6D8bpf
# m4CLKczsG7ZrIGNTAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
# A1UdDgQWBBTvb1NK6eQGfHrK4pBW9i/USezLTjAfBgNVHSMEGDAWgBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3Js
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsF
# AAOCAgEAF877FoAc/gc9EXZxML2+C8i1NKZ/zdCHxYgaMH9Pw5tcBnPw6O6FTGNp
# oV2V4wzSUGvI9NAzaoQk97frPBtIj+ZLzdp+yXdhOP4hCFATuNT+ReOPK0mCefSG
# +tXqGpYZ3essBS3q8nL2UwM+NMvEuBd/2vmdYxDCvwzJv2sRUoKEfJ+nN57mQfQX
# wcAEGCvRR2qKtntujB71WPYAgwPyWLKu6RnaID/B0ba2H3LUiwDRAXx1Neq9ydOa
# l95CHfmTnM4I+ZI2rVQfjXQA1WSjjf4J2a7jLzWGNqNX+DF0SQzHU0pTi4dBwp9n
# EC8EAqoxW6q17r0z0noDjs6+BFo+z7bKSBwZXTRNivYuve3L2oiKNqetRHdqfMTC
# W/NmKLJ9M+MtucVGyOxiDf06VXxyKkOirv6o02OoXN4bFzK0vlNMsvhlqgF2puE6
# FndlENSmE+9JGYxOGLS/D284NHNboDGcmWXfwXRy4kbu4QFhOm0xJuF2EZAOk5eC
# khSxZON3rGlHqhpB/8MluDezooIs8CVnrpHMiD2wL40mm53+/j7tFaxYKIqL0Q4s
# sd8xHZnIn/7GELH3IdvG2XlM9q7WP/UwgOkw/HQtyRN62JK4S1C8uw3PdBunvAZa
# psiI5YKdvlarEvf8EA+8hcpSM9LHJmyrxaFtoza2zNaQ9k+5t1wwggbtMIIE1aAD
# AgECAhAKgO8YS43xBYLRxHanlXRoMA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQg
# VHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEw
# HhcNMjUwNjA0MDAwMDAwWhcNMzYwOTAzMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFNIQTI1
# NiBSU0E0MDk2IFRpbWVzdGFtcCBSZXNwb25kZXIgMjAyNSAxMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEA0EasLRLGntDqrmBWsytXum9R/4ZwCgHfyjfM
# GUIwYzKomd8U1nH7C8Dr0cVMF3BsfAFI54um8+dnxk36+jx0Tb+k+87H9WPxNyFP
# JIDZHhAqlUPt281mHrBbZHqRK71Em3/hCGC5KyyneqiZ7syvFXJ9A72wzHpkBaMU
# Ng7MOLxI6E9RaUueHTQKWXymOtRwJXcrcTTPPT2V1D/+cFllESviH8YjoPFvZSjK
# s3SKO1QNUdFd2adw44wDcKgH+JRJE5Qg0NP3yiSyi5MxgU6cehGHr7zou1znOM8o
# dbkqoK+lJ25LCHBSai25CFyD23DZgPfDrJJJK77epTwMP6eKA0kWa3osAe8fcpK4
# 0uhktzUd/Yk0xUvhDU6lvJukx7jphx40DQt82yepyekl4i0r8OEps/FNO4ahfvAk
# 12hE5FVs9HVVWcO5J4dVmVzix4A77p3awLbr89A90/nWGjXMGn7FQhmSlIUDy9Z2
# hSgctaepZTd0ILIUbWuhKuAeNIeWrzHKYueMJtItnj2Q+aTyLLKLM0MheP/9w6Ct
# juuVHJOVoIJ/DtpJRE7Ce7vMRHoRon4CWIvuiNN1Lk9Y+xZ66lazs2kKFSTnnkrT
# 3pXWETTJkhd76CIDBbTRofOsNyEhzZtCGmnQigpFHti58CSmvEyJcAlDVcKacJ+A
# 9/z7eacCAwEAAaOCAZUwggGRMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOQ7/PIx
# 7f391/ORcWMZUEPPYYzoMB8GA1UdIwQYMBaAFO9vU0rp5AZ8esrikFb2L9RJ7MtO
# MA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCBlQYIKwYB
# BQUHAQEEgYgwgYUwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBdBggrBgEFBQcwAoZRaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3J0
# MF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNy
# bDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQEL
# BQADggIBAGUqrfEcJwS5rmBB7NEIRJ5jQHIh+OT2Ik/bNYulCrVvhREafBYF0RkP
# 2AGr181o2YWPoSHz9iZEN/FPsLSTwVQWo2H62yGBvg7ouCODwrx6ULj6hYKqdT8w
# v2UV+Kbz/3ImZlJ7YXwBD9R0oU62PtgxOao872bOySCILdBghQ/ZLcdC8cbUUO75
# ZSpbh1oipOhcUT8lD8QAGB9lctZTTOJM3pHfKBAEcxQFoHlt2s9sXoxFizTeHihs
# QyfFg5fxUFEp7W42fNBVN4ueLaceRf9Cq9ec1v5iQMWTFQa0xNqItH3CPFTG7aEQ
# JmmrJTV3Qhtfparz+BW60OiMEgV5GWoBy4RVPRwqxv7Mk0Sy4QHs7v9y69NBqycz
# 0BZwhB9WOfOu/CIJnzkQTwtSSpGGhLdjnQ4eBpjtP+XB3pQCtv4E5UCSDag6+iX8
# MmB10nfldPF9SVD7weCC3yXZi/uuhqdwkgVxuiMFzGVFwYbQsiGnoa9F5AaAyBjF
# BtXVLcKtapnMG3VH3EmAp/jsJ3FVF3+d1SVDTmjFjLbNFZUWMXuZyvgLfgyPehwJ
# VxwC+UpX2MSey2ueIu9THFVkT+um1vshETaWyQo8gmBto/m3acaP9QsuLj3FNwFl
# Txq25+T4QwX9xa6ILs84ZPvmpovq90K8eWyG2N01c4IhSOxqt81nMIIHDjCCBXag
# AwIBAgIQSw+NgvCzdrKXturaTqbU7DANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgRVYgUjM2MB4XDTIzMDUzMDAwMDAwMFoX
# DTI2MDUyOTIzNTk1OVowgdQxEjAQBgNVBAUTCUhSQiAyMTAxNTETMBEGCysGAQQB
# gjc8AgEDEwJERTEdMBsGA1UEDxMUUHJpdmF0ZSBPcmdhbml6YXRpb24xCzAJBgNV
# BAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xNTAzBgNVBAoMLFNPUyBTb2Z0d2FyZS0g
# dW5kIE9yZ2FuaXNhdGlvbnMtU2VydmljZSBHbWJIMTUwMwYDVQQDDCxTT1MgU29m
# dHdhcmUtIHVuZCBPcmdhbmlzYXRpb25zLVNlcnZpY2UgR21iSDCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAL5t1usDS85Xcw3cIgVDvb43V9y9hiRn8cWn
# pnYrW8KcS58120n0rRCXPW8sFJvm4Uqf1xs1sXkmyBrdd0p/RBaKTkWtuScbsAPM
# UxDsSzPwhJYD/2jfv65ebB82qSURfO4ne8iF75WccYrgD2b6ZE3Px1ks/yH2zTw7
# VjSYZgjpYhiUd215hTxwww35a32OS/f79sMi1ERC8qcVQYudwGm2brYgGuNC0qqL
# 1Z3W2EPKkH3VvUFUSQxdIQzEPMZrt9ZAepizAlyv/UZuxdmIr9DTL4OId6od5Ffp
# Cx8xHGiDHgULvlbQj7zBJ/GoUUcPNG5Ye1dn/Tl9xkcmJ9A0H4zGXRo6Zo+D9MZX
# avBntj1ZvqwlCXiUkFGLDtay4TMgQKDJfs+qocFrsYeXCWiWqw0Ly1qYsa4rAPgC
# TSVJ4j8l06/nWU0r57dvXRt9AuuikbJBSlg7gc462gK95FFkACeZEuhtSkrsnW8Y
# FpPfTI7fomhyyg5bHiRKlyHq3Hgr7C88PjTmLAOQDhHQs/jgi3aMEDNHrTcFoHBl
# YmQbsnU9zr0PMOUJXSRF1PsIe2vvvw9rpfvuLobUN21g1spNuEil+jrKgxYHKxcV
# qvlSVn5SISqhQPYRGbLeZPIB2ZMl5w+z5Wwg6HqrdrD1MomSkPwWNxEjjSg3Ph2W
# izBtgEY3AgMBAAGjggHWMIIB0jAfBgNVHSMEGDAWgBSBMpJBKyjNRsjEosYqORLs
# SKk/FDAdBgNVHQ4EFgQURHB21fi7IRRpsoiNNppx0kxQ2YIwDgYDVR0PAQH/BAQD
# AgeAMAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwSQYDVR0gBEIw
# QDA1BgwrBgEEAbIxAQIBBgEwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdv
# LmNvbS9DUFMwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5z
# ZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQUVWUjM2LmNybDB7
# BggrBgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FFVlIzNi5jcnQwIwYIKwYBBQUH
# MAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMEgGA1UdEQRBMD+gHAYIKwYBBQUH
# CAOgEDAODAxERS1IUkIgMjEwMTWBH2FuZHJlYXMucHVlc2NoZWxAc29zLWJlcmxp
# bi5jb20wDQYJKoZIhvcNAQELBQADggGBAGQVsECtVc3Unom81ITXzXk3s9N6nMrs
# yxIXBTtFpa1Kq/oRZjhL3YuHZmA3kSpi8NjO0TvpI17KE/lEB8tm8qxLAOTCQ7l2
# CskAbcz5LIFKDbz+fm694GaeAp82KaxE45/V+esji36D8VKtywDABarTZADXxpIf
# Q5+9sLNy0dzpCwUcUrw0UArob6Nrom8F6nS9fcBoD8hLx/WIwZyhpKYGmKtEhpF7
# lsK7IxU2/t9N53NzfJ+vmSuMRKdZu1uoANx9PXkWolihmfR/J82HoYLM7okZGbhM
# zT3x6DOn0tir+mCOIcgk8iMA1nxkucPiWBHYYn3LxP8afogSk11Hxk5m9ZHvdrqs
# HZU30lf7ERzm7zCjaExsdT/1GtUJlNytDrJQyK0JtiP3CxxuZrGh8bFONRTpDHkr
# ff1ag/XGPZR+yLCWgqmO3JgoPLRAkPlIIJEka+4MDuRo36OzTrTkSKAYm4uGA9xa
# cldGojre4aXgSKndSSBFrQ9RqVAOwOqqgzGCBkcwggZDAgEBMGswVzELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGln
# byBQdWJsaWMgQ29kZSBTaWduaW5nIENBIEVWIFIzNgIQSw+NgvCzdrKXturaTqbU
# 7DANBglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMC8GCSqGSIb3DQEJBDEiBCAi7PEAKRqDn4QuJmyy2NMpwWtvSXNIhqHT
# Ifbao+UonjANBgkqhkiG9w0BAQEFAASCAgCQfbOvok++GCq2Dso0ml2+n5Zv9ClW
# RQneCr7iTzHDtTpCxPI79N03POOCkH0IxNvjl/xm7XAKGx+A8Zwb1nKVum2bm/dL
# Oy0SNpKTGou3LnIWXZzTCdtkMIi/4hSiU7O709jP1fbrapnO4GxFE4vG1J5YQWaQ
# PlU2eh+hV3yqKL4qi0ruxW/rWRFxAhPsixFw2PpktpuOGSdBifEYsIMggL/WZUVP
# /zBdYdm4DEbJb+ebqp6X9T22rp+0dI5DiSzq+VlRUtHLUkYnfJrpp3G40IeNDEUp
# 99Ks/JOYtbInc9Wtg8WDMOrqlC0/iwhZOdovYvpTPkxN9lSWfvh/IasbAxiI3oxo
# XSupBwMyn16vYM2BU+sTEPvfVhXz5nmF00hpnTiCuLfAEvH9Gcqet44qhXVHPFsj
# Qwka/2z8woPc2lD6zBPs12Uo6jZ2i3cForAgoohmc544S3L8VdknEIHM/x2xFWO3
# Iw1T8fjFndOqAkqFLmN1PFJWvqEgGf7mUPWuwvxeby2AR1gsYL93BvGYxppCkcRm
# r2d+I4taTowd4BnRW4qe6iaBSc/rePVYsrUUUju5GImlEZcoZMlHx4wk9s5E0939
# ZiWaHYaejuXDZY8on4kP52IhM7sG3BEHJrHu+wau2AzxFirVOJlv3y3ogmeQ1o5s
# LQIGLR21Q6Jna6GCAyYwggMiBgkqhkiG9w0BCQYxggMTMIIDDwIBATB9MGkxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGln
# aUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAy
# NSBDQTECEAqA7xhLjfEFgtHEdqeVdGgwDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNjAxMDYwNDEzMTha
# MC8GCSqGSIb3DQEJBDEiBCCw3xz8JpOBT8ywTNBYFzo6L2ZcRSF8r8sney3Mm8W5
# PjANBgkqhkiG9w0BAQEFAASCAgBHRYDa93QayxSqSewfwgjRboWeksvM4jtdFH0f
# U4EsgPMpGa8toCDsQWto1MpxrXVeP/BiPgr7xsPzzu/nFNcpvua1Zg53qZdn9nuP
# eMKI30p4hhmoAbxmDy9hVfyGsI1ZQfLH6521gWVoPlGrdmY3A+5bKOEcK1cQnVwd
# pXEkidq6dpRLxiA3xmWFsCqsYi3yD7q9jg2ZSK+dyr6gEQxVOOLphR4hvO6VFNcY
# lqGkLGQ2VWVw0GKJjMCTJbVOuNt6UR6YMCzdg1fIuZJfm/IJGWkubgITcLq/0uTh
# SsdTdIV9ABs4R8tpB1cCF3PXgwt1ZBsjJBg5JAy4qmpS2QSshmTZELofjjpCDxNX
# 6f7u8pJpzYUCK4R74TnnamQmpfrgfZSzyLk9rxzBZvpTGLyhhYgxxwGiBncEgXN7
# YW2dT4d7y0UaZ546SgFFUvpDm6ZkC2PeSMePQehTntePk9nArUf9WlYOsPrzebJR
# DwYijjPCIOJVXFL5sMpVr6twCez8xE80YgPvtMR3SBoEOtFFm5Hgruj+A5pZbpbl
# rbTzOv80wiPmpflvrRWYWykT0hyPblg6xjkJX/5axhNmzMra3UvZk4Pqs+CtNNYF
# mDOkCsJHsFK03Yo7sATwJ1vDLsccPw6ykdRfwnm9ZHu4L7h+anYbBR91ISQtzXm7
# S0gXxw==
# SIG # End signature block
