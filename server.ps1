Set-Location c:\vagrant

# NB to be compatible with most WebRTC clients, use the YUV420p pixel format
#    and the H.264 video codec without B-frames (i.e. the baseline profile).
# see https://trac.ffmpeg.org/wiki/Encode/H.264
if (!(Test-Path smptebars.mp4)) {
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
        smptebars.mp4
}

mediamtx
