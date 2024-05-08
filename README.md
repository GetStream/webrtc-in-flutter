# webrtc_in_flutter

📱 This project demonstrates WebRTC protocol to facilitate real-time video communications with Flutter.

This guide is a simplified version of the tutorial for the [flutter_webrtc](https://github.com/flutter-webrtc/flutter-webrtc) plugin found [here](https://github.com/flutter-webrtc/flutter-webrtc-demo).

## ✍️ Technical Content

If you're interested in knowing more about building a Flutter WebRTC app, check out the following blog post: **[WebRTC Video Calling with Flutter](https://getstream.io/resources/projects/webrtc/platforms/flutter/)**

## 🛥 Stream Chat & Video SDK

**Generative AI with Flutter** is built with __[Stream Chat SDK for Flutter](https://getstream.io/chat/sdk/flutter/?utm_source=github&utm_medium=referral&utm_content=&utm_campaign=devenossproject)__ to implement messaging systems. If you’re interested in building powerful real-time video/audio calling, audio room, and livestreaming, check out the __[Stream Video SDK for Flutter](https://getstream.io/video/sdk/flutter/tutorial/video-calling/?utm_source=github&utm_medium=referral&utm_content=&utm_campaign=devenossproject)__!

### Stream Chat

- [Stream Chat SDK for Flutter on GitHub](https://github.com/getStream/stream-chat-flutter)
- [Flutter Samples for Stream Chat SDK on GitHub](https://github.com/getStream/flutter-samples)

### Stream Video

- [Stream Video SDK for Flutter on GitHub](https://github.com/getstream/stream-video-flutter?utm_source=github&utm_medium=referral&utm_content=&utm_campaign=devenossproject)
- [Video Call Tutorial](https://getstream.io/video/sdk/flutter/tutorial/video-calling/?utm_source=github&utm_medium=referral&utm_content=&utm_campaign=devenossproject)
- [Audio Room Tutorial](https://getstream.io/video/sdk/flutter/tutorial/audio-room/?utm_source=github&utm_medium=referral&utm_content=&utm_campaign=devenossproject)
- [Livestream Tutorial](https://getstream.io/video/sdk/flutter/tutorial/livestreaming/?utm_source=github&utm_medium=referral&utm_content=&utm_campaign=devenossproject)

## 💻 How to build the project?

This project contains the app that can be used for P2P calls on Flutter. However, there is also a signaling server needed for the same.

The signaling server used by the app is the [flutter_webrtc_server](https://github.com/flutter-webrtc/flutter-webrtc-server) which also needs to be used.

To run the signaling server, clone the project and change the directory to the project. 

Then run these commands to generate a certificate:

```bash
brew update
brew install mkcert
mkcert -key-file configs/certs/key.pem -cert-file configs/certs/cert.pem  localhost 127.0.0.1 ::1 0.0.0.0
```

And then these commands to run the server: 

```bash
brew install golang
go run cmd/server/main.go
```

You can then use https://0.0.0.0:8086 to use the web demo provided by the project.
