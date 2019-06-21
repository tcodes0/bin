#! /usr/bin/env bash

# exit on errors
set -e

ANDROID_SDK_PATH=$HOME/Library/Android/sdk
BUILD_TOOLS_VERSION=28.0.0
OUTPUT_PATH=$HOME/Desktop/app-release.apk
PATH_TO_UNSIGNED_APK=$PWD/app/build/outputs/apk/release/app-release-unsigned.apk

if [ "$#" == 0 ]; then
  echo 'android-build-sign sense|scatter [install]'
  exit
fi

if [ ! -f package.json ]; then
  echo 'This doesnt look like a react native project root';
  exit 1
fi

if [ "$1" == "sense" ]; then
  PATH_TO_KEYSTORE=$HOME/Code/foton/keys/sense.keystore
  KEY_PASSWORD='ab43#2JKa!'
  KEY_ALIAS=release-key
fi
if [ "$1" == "scatter" ]; then
  PATH_TO_KEYSTORE=$HOME/Code/foton/keys/scatter.keystore
  KEY_PASSWORD='g^;kYdI2?KM=_kz_9#KseY-~m_84wnqnUmX_HV?uWfBDo:pvs#'
  KEY_ALIAS=release-key
fi

if [ -f "$OUTPUT_PATH" ]; then
  mv "$OUTPUT_PATH" "$OUTPUT_PATH"-old
  trash "$OUTPUT_PATH"-old
fi

# make apk
# apk path will likely be: android/app/build/outputs/apk/release/app-release-unsigned.apk
cd android
./gradlew assembleRelease

# on my machine jarsigner is at /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/jarsigner
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$PATH_TO_KEYSTORE" "$PATH_TO_UNSIGNED_APK" $KEY_ALIAS -storepass "$KEY_PASSWORD"

# on my machine android sdk is at $HOME/Library/Android/sdk
# on my machine I have many build tools versions, I used 28.0.0
# you can choose the path of the signed apk, for example app/build/outputs/apk/release/app-release.apk
"$ANDROID_SDK_PATH"/build-tools/$BUILD_TOOLS_VERSION/zipalign -v 4 "$PATH_TO_UNSIGNED_APK" "$OUTPUT_PATH"

"$ANDROID_SDK_PATH"/build-tools/$BUILD_TOOLS_VERSION/apksigner verify "$OUTPUT_PATH"

if [ "$2" == 'install' ]; then
  adb install "$OUTPUT_PATH"
fi
