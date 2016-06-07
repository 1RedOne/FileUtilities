$D_Drive = "D:\Photos\Eye-Fi\*"
$E_Drive = "R:\Photos\Eye-Fi"

$dropboxD = "D:\Photos\LG g4\*"
$dropboxE = "R:\Photos\LG g4"

#Copy-Item -Path $D_Drive -Destination $E_Drive -Recurse -PassThru -ErrorAction SilentlyContinue | Select @{Name="Action";Exp={"EyeFi D: to E:"}},BaseName,Extension,Length,Directory | Tee-Object -Variable movedItems
$movedItems = Copy-Item -Path $dropboxD -Destination $dropboxE -Recurse -PassThru -ErrorAction SilentlyContinue| Select @{Name="Action";Exp={"Copy to Backup Drive"}},BaseName,Extension,Length,Directory


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



#$HTMLbase | out-file R:\backup\AzureBackup_$((Get-Date -UFormat "%Y-%m-%d"))_Log.html 

#$body  = $movedItems | ConvertTo-Html -pre "This list contains EyeFi items that were moved from the <b>D: drive</b> to the <b>E: Drive</b>" -PostContent '<hr>'
#$body += $movedItems2 | ConvertTo-Html -pre "This list contains items that were moved from the <b>D: drive</b> to the <b>E: Drive</b>" -Fragment 

$HTMLbase = $movedItems | ConvertTo-Html -Head $header -CssUri "C:\Users\Stephen\Dropbox\Speaking\Demos\style.css" `
                            -Title ("Dropbox Backup Report for $((Get-Date -UFormat "%Y-%m-%d"))") `
                            -PostContent $post `
                            -pre "This list contains EyeFi items that were moved from the <b>D: drive</b> to the <b>R: Drive</b>"
                                            

$HTMLbase | out-file r:\Backups\BuckyBackup_$((Get-Date -UFormat "%Y-%m-%d"))_Log.html 

start r:\Backups\BuckyBackup_$((Get-Date -UFormat "%Y-%m-%d"))_Log.html