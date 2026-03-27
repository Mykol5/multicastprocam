# MultiCast Pro Cam

A cross-platform streaming application like Irene webcam that allows multiple mobile devices to stream video/audio to a web viewer.

## Features

- 📱 Mobile app for streamers (Android)
- 🌐 Web app for viewers
- 🎥 Real-time video/audio streaming
- 👥 Support for multiple streamers (4+)
- 🔄 Switch between streams on web
- 🚀 Built with Flutter and WebRTC

## Architecture

- **Flutter Mobile**: Streamer app with camera/mic access
- **Flutter Web**: Viewer app with multi-stream switching
- **Node.js Signaling Server**: WebRTC signaling and room management

## Quick Start

### 1. Deploy Signaling Server to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

Or manually:
```bash
cd signaling_server
npm install
npm start
