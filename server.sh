#!/usr/bin/env bash
set -euxo pipefail

docker build -t mediamtx-rtsp-server .

docker run --rm --net=host -it mediamtx-rtsp-server
