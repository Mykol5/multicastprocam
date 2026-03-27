#!/bin/bash
# setup.sh - Script to setup Flutter project

# Backup custom lib if exists
if [ -d "lib" ]; then
  cp -r lib ../lib_backup
fi

# Go back to root
cd ..

# Delete old flutter_app
rm -rf flutter_app

# Create fresh Flutter project
flutter create flutter_app --platforms=android,web

# Restore custom lib
if [ -d "lib_backup" ]; then
  rm -rf flutter_app/lib
  mv lib_backup flutter_app/lib
fi

# Write correct pubspec.yaml
cat > flutter_app/pubspec.yaml << 'EOF'
name: multicast_pro
description: MultiCast Pro
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_webrtc: ^0.9.47
  socket_io_client: ^2.0.1
  permission_handler: ^11.0.0
  provider: ^6.1.0
  universal_platform: ^1.0.0+1
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# Get dependencies
cd flutter_app
flutter pub get
