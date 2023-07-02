# About

Use the [MediaMTX](https://github.com/bluenviron/mediamtx) RTSP server to stream a MP4 file.

# Usage (Ubuntu Desktop 22.04)

Install docker.

Start the RTSP server:

```bash
./server.sh
```

Install VLC:

```bash
# remove the debian/ubuntu package.
# NB it does not support RTSP due to live555 licensing concerns.
sudo apt-get remove -y --purge 'vlc*'
# install the snap package.
sudo snap install vnc
hash -r
```

In another shell, start the RTSP client:

```bash
./client.sh
```

# Alternatives

* http://www.live555.com/mediaServer/
