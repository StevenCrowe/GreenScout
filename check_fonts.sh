#!/bin/bash

echo "Checking font files in project..."
echo "================================"

# Check if fonts exist in project
echo -e "\n1. Font files in project:"
ls -la /Users/stevencrowe/Documents/GreenScout/GreenScout/GreenScout/Fonts/*.ttf

# Check if build directory exists
echo -e "\n2. Looking for built app bundles:"
find /Users/stevencrowe/Documents/GreenScout/GreenScout/build -name "*.app" -type d 2>/dev/null | head -5

# Check DerivedData (common Xcode build location)
echo -e "\n3. Checking DerivedData for GreenScout app:"
find ~/Library/Developer/Xcode/DerivedData -name "GreenScout.app" -type d 2>/dev/null | head -5

# If app bundle found in build directory, check its contents
echo -e "\n4. Checking if fonts are in app bundle (if found):"
APP_PATH=$(find /Users/stevencrowe/Documents/GreenScout/GreenScout/build -name "GreenScout.app" -type d 2>/dev/null | head -1)
if [ -n "$APP_PATH" ]; then
    echo "Found app at: $APP_PATH"
    echo "Fonts in app bundle:"
    ls -la "$APP_PATH"/*.ttf 2>/dev/null || echo "No .ttf files found in app bundle root"
    ls -la "$APP_PATH"/Fonts/*.ttf 2>/dev/null || echo "No Fonts folder in app bundle"
else
    echo "No app bundle found in build directory"
fi

echo -e "\nDone."
