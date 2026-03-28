#!/bin/bash
echo "Setting up MultiCast Pro..."

cd ..

# Create fresh Flutter project
rm -rf flutter_app
flutter create flutter_app --platforms=android,web,windows,macos,linux

# Copy our lib files (they're already in the repo)
if [ -d "lib_backup" ]; then
    rm -rf flutter_app/lib
    mv lib_backup flutter_app/lib
fi

cd flutter_app

# Fix Android SDK and add permissions
cat > android/app/build.gradle << 'EOF'
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.multicast.pro"
    compileSdkVersion 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.multicast.pro"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
EOF

# Update AndroidManifest.xml with all permissions
cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    
    <!-- For Android 12+ -->
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
    
    <!-- For camera feature -->
    <uses-feature android:name="android.hardware.camera" android:required="true"/>
    <uses-feature android:name="android.hardware.camera.autofocus"/>
    
    <application
        android:label="MultiCast Pro"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
EOF

# Update pubspec.yaml
cat > pubspec.yaml << 'EOF'
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

flutter pub get
echo "Setup complete!"














# #!/bin/bash
# echo "Setting up MultiCast Pro..."

# cd ..

# # Create fresh Flutter project
# rm -rf flutter_app
# flutter create flutter_app --platforms=android,web,windows,macos,linux

# # Copy our lib files (they're already in the repo)
# if [ -d "lib_backup" ]; then
#     rm -rf flutter_app/lib
#     mv lib_backup flutter_app/lib
# fi

# cd flutter_app

# # Fix Android SDK
# cat > android/app/build.gradle << 'EOF'
# def localProperties = new Properties()
# def localPropertiesFile = rootProject.file('local.properties')
# if (localPropertiesFile.exists()) {
#     localPropertiesFile.withReader('UTF-8') { reader ->
#         localProperties.load(reader)
#     }
# }

# def flutterRoot = localProperties.getProperty('flutter.sdk')
# if (flutterRoot == null) {
#     throw new GradleException("Flutter SDK not found.")
# }

# def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
# if (flutterVersionCode == null) {
#     flutterVersionCode = '1'
# }

# def flutterVersionName = localProperties.getProperty('flutter.versionName')
# if (flutterVersionName == null) {
#     flutterVersionName = '1.0'
# }

# apply plugin: 'com.android.application'
# apply plugin: 'kotlin-android'
# apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

# android {
#     namespace "com.multicast.pro"
#     compileSdkVersion 34

#     compileOptions {
#         sourceCompatibility JavaVersion.VERSION_1_8
#         targetCompatibility JavaVersion.VERSION_1_8
#     }

#     kotlinOptions {
#         jvmTarget = '1.8'
#     }

#     defaultConfig {
#         applicationId "com.multicast.pro"
#         minSdkVersion 21
#         targetSdkVersion 34
#         versionCode flutterVersionCode.toInteger()
#         versionName flutterVersionName
#     }

#     buildTypes {
#         release {
#             signingConfig signingConfigs.debug
#         }
#     }
# }

# flutter {
#     source '../..'
# }

# dependencies {
#     implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
# }
# EOF

# # Update pubspec
# cat > pubspec.yaml << 'EOF'
# name: multicast_pro
# description: MultiCast Pro
# publish_to: 'none'
# version: 1.0.0+1

# environment:
#   sdk: '>=3.0.0 <4.0.0'

# dependencies:
#   flutter:
#     sdk: flutter
#   flutter_webrtc: ^0.9.47
#   socket_io_client: ^2.0.1
#   permission_handler: ^11.0.0
#   provider: ^6.1.0
#   universal_platform: ^1.0.0+1
#   uuid: ^4.0.0

# dev_dependencies:
#   flutter_test:
#     sdk: flutter
#   flutter_lints: ^3.0.0

# flutter:
#   uses-material-design: true
# EOF

# flutter pub get
# echo "Setup complete!"
