#!/bin/bash
# setup.sh - Complete setup script for MultiCast Pro (Mobile + Web + Desktop)

echo "📱 Setting up MultiCast Pro Flutter project..."

# Backup custom lib if exists
if [ -d "lib" ]; then
  echo "📁 Backing up custom lib folder..."
  cp -r lib ../lib_backup
fi

# Go back to root
cd ..

# Delete old flutter_app if exists
if [ -d "flutter_app" ]; then
  echo "🗑️  Removing old flutter_app..."
  rm -rf flutter_app
fi

# Create fresh Flutter project with ALL platforms (Android, iOS, Web, Windows, macOS, Linux)
echo "🏗️  Creating new Flutter project with all platforms..."
flutter create flutter_app --platforms=android,ios,web,windows,macos,linux

# Restore custom lib
if [ -d "lib_backup" ]; then
  echo "📁 Restoring custom lib folder..."
  rm -rf flutter_app/lib
  mv lib_backup flutter_app/lib
fi

# Now fix everything in flutter_app
cd flutter_app

# 1. Fix Android build.gradle with correct SDK versions AND namespace
echo "🔧 Fixing Android build.gradle..."
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
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
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

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
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

# 2. Update gradle.properties
echo "🔧 Updating gradle.properties..."
cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx4G
android.useAndroidX=true
android.enableJetifier=true
EOF

# 3. Update gradle-wrapper.properties
echo "🔧 Updating gradle-wrapper.properties..."
cat > android/gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# 4. Update pubspec.yaml
echo "📦 Updating pubspec.yaml..."
cat > pubspec.yaml << 'EOF'
name: multicast_pro
description: MultiCast Pro - Cross-platform streaming
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
  
  # Desktop-specific permissions (for Windows/macOS/Linux)
  window_manager: ^0.3.0
  screen_retriever: ^0.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# 5. Update AndroidManifest.xml
echo "🔧 Updating AndroidManifest.xml..."
cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    
    <application
        android:label="MultiCast Pro"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
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

# 6. Get dependencies
echo "📥 Installing dependencies..."
flutter pub get

# 7. Enable desktop support (if not already)
echo "🖥️  Enabling desktop support..."
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# 8. Verify settings
echo "✅ Verifying Android SDK settings..."
grep "minSdkVersion" android/app/build.gradle
grep "namespace" android/app/build.gradle

echo "✅ Setup complete! Building all platforms..."
