#!/bin/bash

# Function to wait for app to settle
wait_for_app() {
    sleep 3
}

# Function to capture screenshot
capture_screenshot() {
    local device_id=$1
    local mode=$2
    local device_type=$3
    local filename=$4
    local description=$5
    
    echo "Capturing: $description"
    xcrun simctl io $device_id screenshot "Screenshots/$mode/$device_type/$filename"
}

# Simulator device ID
SIMULATOR_ID="E5523B02-EA91-4DF2-B4F5-190A107302B5"

# Kill the app if running
xcrun simctl terminate $SIMULATOR_ID com.goldacres.GreenScout 2>/dev/null

# Test Light Mode
echo "=== Testing Light Mode on Simulator ==="
xcrun simctl ui $SIMULATOR_ID appearance light
wait_for_app

# Launch app
xcrun simctl launch $SIMULATOR_ID com.goldacres.GreenScout
wait_for_app

# Main screen
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "01_main_screen.png" "Main screen with tab bar in Light mode"

echo ""
echo "Light mode screenshots captured. Please manually navigate through the app and take additional screenshots:"
echo "1. Tap on 'Select from Photos' or 'Take Photo' button"
echo "2. Navigate to each tab (Calculator, Chemicals, History, Settings)"
echo "3. Open any modal sheets or dialogs"
echo ""
echo "Press Enter when ready to switch to Dark mode..."
read

# Kill app
xcrun simctl terminate $SIMULATOR_ID com.goldacres.GreenScout

# Test Dark Mode
echo -e "\n=== Testing Dark Mode on Simulator ==="
xcrun simctl ui $SIMULATOR_ID appearance dark
wait_for_app

# Launch app
xcrun simctl launch $SIMULATOR_ID com.goldacres.GreenScout
wait_for_app

# Main screen
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "01_main_screen.png" "Main screen with tab bar in Dark mode"

echo ""
echo "Dark mode screenshots captured. Please manually navigate through the app and take additional screenshots."
echo ""
echo "=== Screenshot capture complete ==="
echo "Screenshots saved in Screenshots/Light/Simulator and Screenshots/Dark/Simulator"
echo ""
echo "For real device testing:"
echo "1. Connect your iPhone (ID: 329DB90F-4067-516A-986D-36BD72EB9AFF)"
echo "2. Build for device: xcodebuild -project GreenScout.xcodeproj -scheme GreenScout -destination 'id=329DB90F-4067-516A-986D-36BD72EB9AFF' build"
echo "3. In Settings > Display & Brightness, set to Light appearance"
echo "4. Take screenshots and save to Screenshots/Light/Device"
echo "5. Switch to Dark appearance and repeat for Screenshots/Dark/Device"
