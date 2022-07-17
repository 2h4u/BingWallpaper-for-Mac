#!/bin/sh

# Build
xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -alltargets

# ZIP
cd ./build/Release/
zip -r ../../BingWallpaper_latest.zip ./BingWallpaper.app
cd ../../

echo "Done"
