# syntax=docker/dockerfile:1.9
# see https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md
# see https://hub.docker.com/r/docker/dockerfile

FROM alpine:3.20

RUN <<"EOF"
set -euxo pipefail
apk --no-cache add \
    ffmpeg \
    font-dejavu
EOF

# NB to be compatible with most WebRTC clients, use the YUV420p pixel format
#    and the H.264 video codec without B-frames (i.e. the baseline profile).
# see https://trac.ffmpeg.org/wiki/Encode/H.264
RUN <<"EOF"
set -euxo pipefail
ffmpeg \
    -f lavfi \
    -i 'smptebars=duration=120:size=640x360:rate=30' \
    -filter:v "drawtext=text='%{pts\\:hms} #%{n}':x=-5:y=3:fontsize=53:fontcolor=white:box=1:boxborderw=3:boxcolor=black:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf" \
    -c:v libx264 \
    -profile:v baseline \
    -pix_fmt yuv420p \
    -preset ultrafast \
    -tune stillimage \
    -movflags +faststart \
    -b:v 600k \
    smptebars.mp4
EOF

# see https://github.com/bluenviron/mediamtx/releases
RUN <<"EOF"
set -euxo pipefail
install -d /tmp/mediamtx
wget -qO- \
    https://github.com/bluenviron/mediamtx/releases/download/v1.8.4/mediamtx_v1.8.4_linux_amd64.tar.gz \
    | tar xzf - -C /tmp/mediamtx
install /tmp/mediamtx/mediamtx /
rm -rf /tmp/mediamtx
EOF

COPY mediamtx.yml .

ENTRYPOINT ["/mediamtx"]
