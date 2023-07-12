# About

Use the [MediaMTX](https://github.com/bluenviron/mediamtx) RTSP server to stream a MP4 file.

# Usage (Ubuntu Desktop 22.04 and Linux container)

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

# Usage (Ubuntu Desktop 22.04 and Windows VM)

Install the [Windows Vagrant Box](https://github.com/rgl/windows-vagrant) and its dependencies.

Launch the VM:

```bash
vagrant up --no-destroy-on-error --provider=libvirt
```

Login the Windows VM desktop.

Wait a few seconds for the desktop to be configured.

Try different client applications and protocols by double clicking the
smptebars links that are on the desktop:

* smptebars VLC RTSP (Real Time Streaming Protocol).
* smptebars MPV RTSP (Real Time Streaming Protocol).
* smptebars ffplay RTSP (Real Time Streaming Protocol).
* smptebars HLS (HTTP Live Streaming).
* smptebars WHEP (WebRTC-HTTP Egress Protocol).

# Alternatives

* http://www.live555.com/mediaServer/
