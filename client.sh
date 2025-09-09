#!/usr/bin/env bash

# start the vlc rtsp client.
# see https://wiki.videolan.org/Documentation:Streaming_HowTo/Command_Line_Examples/#RTSP_live_streaming
if command -v snap &>/dev/null; then
    vlc=("snap" "run" "vlc")
else
    vlc=("vlc")
fi

exec "${vlc[@]}" rtsp://localhost:8554/smptebars
