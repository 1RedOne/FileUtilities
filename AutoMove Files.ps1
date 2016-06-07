$colItems = (Get-ChildItem $home\Dropbox -recurse | Measure-Object -property length -sum)

$NeedToMove = $(($colItems.sum / 1MB) -ge 12000)
"is Dropbox folder bigger than 12GB?: $NeedToMove" 

if ($NeedToMove){
    $files = get-childitem "$home\Dropbox\Camera Uploads\*.mp4" | ? name -notlike *1080*
    forEach ($file in $files){
	 #Round the numbers up for a nice output and then Write-Progress
	$host.ui.rawui.windowtitle = "Processing $i out of $($files.count)"     
$i++  
    $dirname  = $file.DirectoryName
    $baseName = $file.BaseName
    $newname  = "$dirname\$($basename)_1080.mp4"   
	        Write-Progress -Activity "Processing $($basename)" -PercentComplete (($i/$files.Count) * 100) -Status ("$i out of " + $files.Count +" completed "+[math]::Round((($i/$files.Count) * 100),2) +" %")
    ffmpeg -i $file.FullName -n -vf scale=1920:1080 $newname
	

   }
}