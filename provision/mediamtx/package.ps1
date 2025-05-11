# see https://github.com/bluenviron/mediamtx/releases
$archiveVersion = '1.12.2'
$archiveUrl = "https://github.com/bluenviron/mediamtx/releases/download/v${archiveVersion}/mediamtx_v${archiveVersion}_windows_amd64.zip"
$archiveName = Split-Path -Leaf $archiveUrl
$archivePath = "$env:TEMP\$archiveName"

Write-Host "Downloading $archiveName..."
(New-Object Net.WebClient).DownloadFile($archiveUrl, $archivePath)

Write-Host "Extracting $archiveName..."
if (Test-Path tools/mediamtx) {
    Remove-Item -Force -Recurse tools/mediamtx | Out-Null
}
mkdir tools/mediamtx | Out-Null
Expand-Archive $archivePath tools/mediamtx

Write-Host "Creating the mediamtx package..."
Remove-Item *.nupkg
choco pack --version $archiveVersion
