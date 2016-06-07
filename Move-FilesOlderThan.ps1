<#
Create a scheduled task to run this 
$Time = New-ScheduledTaskTrigger -At 12:00 -Once
$User = "Contoso\Administrator"
$PS = PowerShell.exe
Register-ScheduledTask -TaskName "SoftwareScan" -Trigger $Time -User $User -Action $PS
#>

$i = $null


####User Params Here
# \/ This should be the path to your Dropbox camera Uploads folder
$cameraFolder = "C:\Users\Stephen\Dropbox\Camera Uploads"

# \/ If you want to create a copy somewhere else, provide it here
#$SkyDriveFolder = "C:\Users\Stephen\SkyDrive\Pictures\Camera Roll"

# \/ Finally, files are MOVED from your Dropbox folder to this path
$BackupFolder = "g:\Photos\LG g4"

# \/ Place to create status reports
$StatusReportPath = "g:\backups"

# \/ Specify the maximum age of files in days here.  Anything older than this is moved out of the $cameraFolder path
$MoveFilesOlderThanAge = "7"
####End user params


$backupFiles = new-object System.Collections.ArrayList
$itemCount = Get-ChildItem $cameraFolder *.mp4 |  Where-Object LastWriteTime -le ((get-date).AddDays($MoveFilesOlderThanAge)) | Measure-Object | select -ExpandProperty Count

Get-ChildItem $cameraFolder |  Where-Object LastWriteTime -le ((get-date).AddDays($MoveFilesOlderThanAge)) | ForEach-Object {
    $i++ 
    Write-Progress -PercentComplete (($i/$itemCount) * 100) -Status "Moving $_ ($i of $itemCount)" -Activity ("Backup up files older than " + ((get-date).AddDays($MoveFilesOlderThanAge)))
    #Copy-Item -Destination $SkyDriveFolder -Path $_.FullName -PassThru  | select BaseName,Extension,@{Name=‘FileSize‘;Expression={"$([math]::Round($_.Length / 1MB)) MB"}},Length,Directory
    [void]$backupFiles.Add((Move-Item -Destination $BackupFolder -Path $_.FullName -PassThru | select BaseName,Extension,@{Name=‘FileSize‘;Expression={"$([math]::Round($_.Length / 1MB)) MB"}},Length,Directory))
    Start-Sleep -Milliseconds 25
    }

$companyLogo = '<div align=left><img src="C:\Users\Stephen\Dropbox\Speaking\Demos\logo.png"></div>'
$header = @"
 
 $companyLogo
 <h1>File export from Dropbox Report</h1>
 <p>The following automated report was generated at $(Get-Date) and contains the $itemcount files which were older than 
$([math]::Abs($MoveFilesOlderThanAge)) days. <Br><Br>This backup job was executed on System: $($Env:Computername)</p>


 <hr>
"@

$post = @"
 <h3>These items were moved to <b>$BackupFolder</b> for archiving to Azure</h3>
"@

$HTMLbase = $backupFiles | ConvertTo-Html -Head $header -CssUri "C:\Users\Stephen\Dropbox\Speaking\Demos\style.css" `
                            -Title ("Dropbox Backup Report for $((Get-Date -UFormat "%Y-%m-%d"))") `
                            -PostContent $post
                                            

$HTMLbase | out-file $StatusReportPath\DropboxBackup_$((Get-Date -UFormat "%Y-%m-%d"))_Log.html 

& $StatusReportPath\DropboxBackup_$((Get-Date -UFormat "%Y-%m-%d"))_Log.html 
$chrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
