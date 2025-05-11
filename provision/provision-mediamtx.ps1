# install fonts.
# see https://community.chocolatey.org/packages/dejavufonts
choco install -y dejavufonts

# install vlc.
# see https://community.chocolatey.org/packages/vlc
choco install -y vlc --version 3.0.21

# install mpv.
# see https://community.chocolatey.org/packages/mpvio.install
choco install -y mpvio.install --version 0.39.0

# install ffmpeg.
# see https://community.chocolatey.org/packages/ffmpeg
choco install -y ffmpeg --version 7.1.1

# set the mediamtx service configuration.
$serviceHome = "$env:ProgramData\mediamtx"
$serviceConfigPath = "$serviceHome\mediamtx.yml"
if (!(Test-Path $serviceHome)) {
    mkdir $serviceHome | Out-Null
}
if (Test-Path $serviceConfigPath) {
    Remove-Item $serviceConfigPath
}
Copy-Item ..\mediamtx.yml $serviceConfigPath

# create the example video.
# NB to be compatible with most WebRTC clients, use the YUV420p pixel format
#    and the H.264 video codec without B-frames (i.e. the baseline profile).
# see https://trac.ffmpeg.org/wiki/Encode/H.264
$videoPath = "$serviceHome\smptebars.mp4"
if (!(Test-Path $videoPath)) {
    $fontfile = (Resolve-Path "$env:ChocolateyInstall\lib\dejavufonts\*\ttf\DejaVuSansMono.ttf") `
        -replace '\\','/' `
        -replace ':','\\:'
    ffmpeg `
        -f lavfi `
        -i 'smptebars=duration=120:size=640x360:rate=30' `
        -filter:v "drawtext=text='%{pts\:hms} #%{n}':x=-5:y=3:fontsize=53:fontcolor=white:box=1:boxborderw=3:boxcolor=black:fontfile=$fontfile" `
        -c:v libx264 `
        -profile:v baseline `
        -pix_fmt yuv420p `
        -preset ultrafast `
        -tune stillimage `
        -movflags +faststart `
        -b:v 600k `
        $videoPath
}

# install mediamtx and the mediamtx service.
Push-Location mediamtx
./package.ps1
choco install -y --source $PWD mediamtx
Pop-Location
