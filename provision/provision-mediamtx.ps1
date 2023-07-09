# install fonts.
choco install -y dejavufonts

# install vlc.
choco install -y vlc --version 3.0.18

# install mpv.
choco install -y mpvio.install --version 0.35.1

# install ffmpeg.
choco install -y ffmpeg --version 6.0

# install mediamtx.
Push-Location mediamtx
./package.ps1
choco install -y --source $PWD mediamtx
Pop-Location
