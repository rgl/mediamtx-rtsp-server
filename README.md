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

In another shell, start the VLC RTSP client:

```bash
./client.sh
```

To try other protocols, open the following web pages with a web browser:

http://localhost:8889/smptebars (WebRTC-HTTP Egress Protocol (WHEP))
http://localhost:8888/smptebars (HTTP Live Streaming (HLS))

# Alternatives

* http://www.live555.com/mediaServer/
