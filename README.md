# AV desktop streamer

This application is a simple audio and video RTMP streamer and recorder. You can stream any audio and video source on your Mac to a remote RTMP server. 

You can configure audio and video source (including desktop capture), target server, and global shortcut to start/stop. Video and audio source can be set to default or disabled completely. 

The application requires the mic and camera permissions. 

Under the hood the application is using a popular `ffmpeg` tool to stream and capture AV.

## Audio source

You can use the (Blackhole)`https://github.com/ExistentialAudio/BlackHole` utility to create an audio loopback to combine the mic and audio output into a single audio capture device. After that select the new audio device in the AVDstreamer settings.

## How to build 

You need XCode to build the project. You would also need to install the `FFMpegKit` library into the project using XCode. See the `ffmpeg-kit-audio-6.0-macos-xcframework.zip` package at (ffmpeg-kit/releases/tag/v6.0)[https://github.com/arthenica/ffmpeg-kit/releases/tag/v6.0] 


