$env:PATH = "$env:PATH;$env:ProgramFiles\VideoLAN\VLC"

# start the vlc rtsp client.
# see https://wiki.videolan.org/Documentation:Streaming_HowTo/Command_Line_Examples/#RTSP_live_streaming
vlc -vvv rtsp://localhost:8554/smptebars | Out-String -Stream
