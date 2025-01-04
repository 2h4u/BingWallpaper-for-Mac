#!/bin/sh

if [ -f "release.sh" ]; then 
	cd ..
fi

# Build
xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -target BingWallpaperHelper -target BingWallpaper

# ZIP
cd ./build/Release/
zip -r ../../BingWallpaper_latest.zip ./BingWallpaper.app
cd ../../

# PKG
cd ./build/Release/
pkgbuild --root BingWallpaper.app --scripts ../../ReleaseUtils/ --install-location /Applications/BingWallpaper.app ../../BingWallpaper_latest.pkg
cd ../../

echo "Done"
