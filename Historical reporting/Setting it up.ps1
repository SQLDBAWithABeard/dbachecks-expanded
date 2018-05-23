## You will need a database on an instance available to set this up

## Create the tables and trgigers using the sql files

## Add the DbaChecks to a table - You will need to do this every time you update the module to get the new checks

$Instance = ''
$Database = ''
Get-DbcCheck | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Checks -Truncate -Confirm:$False -AutoCreateTable

## Process the Ola Job Names in the table - You will need to do this every time you update the module or update the Ola Job Names configuration

$query = "
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.systemfull) + "' WHERE [Describe] = 'Ola - `$SysFullJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserFull) + "' WHERE [Describe] = 'Ola - `$UserFullJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserDiff) + "' WHERE [Describe] = 'Ola - `$UserDiffJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserLog) + "' WHERE [Describe] = 'Ola - `$UserLogJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.CommandLogCleanup) + "' WHERE [Describe] = 'Ola - `$CommandLogJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.SystemIntegrity) + "' WHERE [Describe] = 'Ola - `$SysIntegrityJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserIntegrity) + "' WHERE [Describe] = 'Ola - `$UserIntegrityJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserIndex) + "' WHERE [Describe] = 'Ola - `$UserIndexJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.OutputFileCleanup) + "' WHERE [Describe] = 'Ola - `$OutputFileJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.DeleteBackupHistory) + "' WHERE [Describe] = 'Ola - `$DeleteBackupJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.PurgeBackupHistory) + "' WHERE [Describe] = 'Ola - `$PurgeBackupJobName'
"
Invoke-DbaSqlQuery -SqlInstance $Instance -Database $Database -Query $query

## Next create configuration using the Set-DbcConfig -Name
## and save it with Export-DbcConfig

## Then run your checks every day with

$Testresults = Invoke-DbcCheck -PassThru -Show Fails

## Add them to the database with 

$Testresults | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Prod_dbachecks_summary_stage -FireTriggers -Truncate -Confirm:$False
$Testresults.TestResult | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Prod_dbachecks_detail_stage -FireTriggers -Truncate -Confirm:$False